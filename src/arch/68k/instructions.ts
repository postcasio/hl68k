import { assert } from "console";
import { readFileSync } from "fs";
import { dirname, resolve } from "path";
import { Block } from "../../compiler/block";
import { Program } from "../../compiler/program";
import { asAbsolute, asIdentifier, asIndirect, asNumber, asString, getRegisterNumber, isAbsolute, isAddressRegisterIdentifier, isDataRegisterIdentifier, isIdentifier, isImmediate, isIndirect, isNumber, isPCRegisterIdentifier, isRegisterList, isSRRegisterIdentifier, isString, isUSPRegisterIdentifier } from "../../compiler/utils";
import { ASTExpressionNode, ASTInstructionNode, ASTRegisterListNode, NodeType } from "../../parser"

export enum OperandSize {
  Byte = 1,
  Word = 1 << 1,
  Long = 1 << 2,
  Short = 1 << 3,
  MacroArg = 1 << 10
}

type ConditionalType = 'T' | 'F' | 'HI' | 'LS' | 'CC' | 'CS' | 'NE' | 'EQ' | 'VC' | 'VS' | 'PL' | 'MI' | 'GE' | 'LT' | 'GT' | 'LE';

const validBranchConditionalBits: ConditionalType[] = [
  'HI', 'LS', 'CC', 'CS', 'NE', 'EQ', 'VC',
  'VS', 'PL', 'MI', 'GE', 'LT', 'GT', 'LE'
];

const validTestDecrementBranchConditionalBits: ConditionalType[] = [
  'LS', 'CC', 'CS', 'LT', 'EQ', 'MI',
  'F', 'NE', 'GE', 'PL', 'GT', 'T',
  'HI', 'VC', 'LE', 'VS'
]

const conditionalBits: Record<ConditionalType, number> = {
  HI: 0b0010,
  LS: 0b0011,
  CC: 0b0100,
  CS: 0b0101,
  NE: 0b0110,
  EQ: 0b0111,
  VC: 0b1000,
  VS: 0b1001,
  PL: 0b1010,
  MI: 0b1011,
  GE: 0b1100,
  LT: 0b1101,
  GT: 0b1110,
  LE: 0b1111,
  T: 0b0000,
  F: 0b0001
}

export function getOperandSize(size: string) {
  switch (size) {
    case 's': return OperandSize.Short;
    case 'b': return OperandSize.Byte;
    case 'w': return OperandSize.Word;
    case 'l': return OperandSize.Long;
    case '$': return OperandSize.MacroArg;
  }

  return 0;
  throw new Error(`Invalid size: ${size}`);
}

enum SizeType {
  Default,
  Alternate,
  Byte
}

const operandSizeBits = {
  [OperandSize.Byte]: 0b00,
  [OperandSize.Word]: 0b01,
  [OperandSize.Long]: 0b10,
  [OperandSize.Short]: 0b00
};

const operandSizeBitsAlt = {
  [OperandSize.Byte]: 0b01,
  [OperandSize.Word]: 0b11,
  [OperandSize.Long]: 0b10,
  [OperandSize.Short]: 0b01
};

const operandSizeBitsByte = {
  [OperandSize.Word]: 0,
  [OperandSize.Long]: 1
};

export const operandByteSizes = {
  [OperandSize.Short]: 1,
  [OperandSize.Byte]: 1,
  [OperandSize.Word]: 2,
  [OperandSize.Long]: 4
}

export enum AddressingMode {
  None = 0,
  DataRegisterDirect = 1,
  AddressRegisterDirect = 1 << 1,
  AddressRegisterIndirect = 1 << 2,
  AddressRegisterIndirectPostIncrement = 1 << 3,
  AddressRegisterIndirectPreDecrement = 1 << 4,
  AddressRegisterIndirectDisplacement = 1 << 5,
  AddressRegisterIndirectIndexDisplacement = 1 << 6,
  ProgramCounterIndirectDisplacement = 1 << 7,
  ProgramCounterIndirectIndexDisplacement = 1 << 8,
  AbsoluteShort = 1 << 9,
  AbsoluteLong = 1 << 10,
  Immediate = 1 << 11,
  RegisterList = 1 << 12
}

const addressingModeBits: Record<AddressingMode, number> = {
  [AddressingMode.None]: 0b000,

  [AddressingMode.DataRegisterDirect]: 0b000,

  [AddressingMode.AddressRegisterDirect]: 0b001,
  [AddressingMode.AddressRegisterIndirect]: 0b010,
  [AddressingMode.AddressRegisterIndirectPostIncrement]: 0b011,
  [AddressingMode.AddressRegisterIndirectPreDecrement]: 0b100,
  [AddressingMode.AddressRegisterIndirectDisplacement]: 0b101,
  [AddressingMode.AddressRegisterIndirectIndexDisplacement]: 0b110,

  [AddressingMode.AbsoluteShort]: 0b111,
  [AddressingMode.AbsoluteLong]: 0b111,
  [AddressingMode.Immediate]: 0b111,

  [AddressingMode.ProgramCounterIndirectDisplacement]: 0b111,
  [AddressingMode.ProgramCounterIndirectIndexDisplacement]: 0b111
};

function getEffectiveAddress(operand: ASTExpressionNode): number {
  const addressingMode = getAddressingMode(operand);
  const modeBits = addressingModeBits[addressingMode] << 3;

  switch (addressingMode) {
    case AddressingMode.DataRegisterDirect:
    case AddressingMode.AddressRegisterDirect:
      return modeBits | getRegisterNumber(asIdentifier(operand));
    case AddressingMode.AddressRegisterIndirect:
    case AddressingMode.AddressRegisterIndirectPostIncrement:
    case AddressingMode.AddressRegisterIndirectPreDecrement:
    case AddressingMode.AddressRegisterIndirectDisplacement:
    case AddressingMode.AddressRegisterIndirectIndexDisplacement:
      return modeBits | getRegisterNumber(asIdentifier(asIndirect(operand).value));
    case AddressingMode.AbsoluteShort:
      return modeBits | 0b000;
    case AddressingMode.AbsoluteLong:
      return modeBits | 0b001;
    case AddressingMode.Immediate:
      return modeBits | 0b100;
    case AddressingMode.ProgramCounterIndirectDisplacement:
      return modeBits | 0b010;
    case AddressingMode.ProgramCounterIndirectIndexDisplacement:
      return modeBits | 0b011;
  }

  throw new Error(`Unknown addressing mode ${addressingMode}`);
}

function getAddressingMode(operand: ASTExpressionNode, size: OperandSize = OperandSize.Long): AddressingMode {
  if (isAbsolute(operand)) {
    if (operand.size == OperandSize.Word) {
      return AddressingMode.AbsoluteShort;
    }
    else {
      return AddressingMode.AbsoluteLong;
    }
  }
  if (isImmediate(operand)) {
    return AddressingMode.Immediate;
  }
  if (isIndirect(operand)) {
    if (isIdentifier(operand.value)) {
      if (isDataRegisterIdentifier(operand.value)) {
        return AddressingMode.DataRegisterDirect;
      }
      if (isAddressRegisterIdentifier(operand.value)) {
        if (operand.index) {
          return AddressingMode.AddressRegisterIndirectIndexDisplacement;
        }
        if (operand.displacement) {
          return AddressingMode.AddressRegisterIndirectDisplacement;
        }
        if (operand.predecrement) {
          return AddressingMode.AddressRegisterIndirectPreDecrement;
        }
        if (operand.postincrement) {
          return AddressingMode.AddressRegisterIndirectPostIncrement;
        }

        return AddressingMode.AddressRegisterIndirect;
      }
      if (isPCRegisterIdentifier(operand.value)) {
        if (operand.index) {
          return AddressingMode.ProgramCounterIndirectIndexDisplacement;
        }

        return AddressingMode.ProgramCounterIndirectDisplacement;
      }
    }
  }
  if (isIdentifier(operand)) {
    if (isAddressRegisterIdentifier(operand)) {
      return AddressingMode.AddressRegisterDirect;
    }
    if (isDataRegisterIdentifier(operand)) {
      return AddressingMode.DataRegisterDirect;
    }
    if (isUSPRegisterIdentifier(operand)) {
      return AddressingMode.AddressRegisterIndirect;
    }
    if (isSRRegisterIdentifier(operand)) {
      return AddressingMode.DataRegisterDirect;
    }

    // return size === OperandSize.Long ? AddressingMode.AbsoluteLong : AddressingMode.AbsoluteShort;
    return AddressingMode.AbsoluteLong;
  }
  if (isRegisterList(operand)) {
    return AddressingMode.RegisterList;
  }

  if (isNumber(operand)) {
    // return size === OperandSize.Long ? AddressingMode.AbsoluteLong : AddressingMode.AbsoluteShort;
    return AddressingMode.AbsoluteLong;
  }

  throw new Error(`Can't determine addressing mode for operand ${JSON.stringify(operand)}`);
}

export interface Instruction {
  mnemonic: string;
  format?: number;
  sizeOffset?: number;
  unsized?: boolean;
  sizeOverridesAbsolute?: boolean;
  effectiveAddressOffset?: number;
  destinationEffectiveAddressOffset?: number;
  destinationEffectiveAddressSwapped?: boolean;
  destinationRegisterOffset?: number;
  sourceRegisterOffset?: number;
  sourceRegisterIsImmediateOffset?: number;
  directionOffset?: number;
  opmodeOffset?: number;
  opmodeSwapped?: boolean;
  opmodeShort?: boolean;
  overrideAbsoluteSize?: OperandSize;

  arguments?: number;
  sizes?: OperandSize;
  size?: OperandSize;
  defaultSize?: OperandSize;
  sizeType?: SizeType;
  addressingModes?: AddressingMode[];
  relativeTarget?: boolean;
  signedTarget?: boolean;
  encoder?: (instruction: ASTInstructionNode, program: Program, block: Block, offset: number) => number[] | number | undefined;
}

function getRegisterListMask(registerList: ASTRegisterListNode, reverse: boolean = false): number {
  let mask = 0;

  for (const entry of registerList.registers) {
    if (isIdentifier(entry)) {
      if (isAddressRegisterIdentifier(entry)) {
        mask |= 1 << (reverse ? (7 - getRegisterNumber(entry)) : (getRegisterNumber(entry) + 8));
      }
      else if (isDataRegisterIdentifier(entry)) {
        mask |= 1 << (reverse ? (15 - getRegisterNumber(entry)) : (getRegisterNumber(entry)));
      }
    }
    else {
      const start = entry.start;
      const end = entry.end;

      let startBitIndex = 0, endBitIndex = 0;

      if (isAddressRegisterIdentifier(start)) {
        startBitIndex = (reverse ? (7 - getRegisterNumber(start)) : (getRegisterNumber(start) + 8));
      }
      else if (isDataRegisterIdentifier(start)) {
        startBitIndex = (reverse ? (15 - getRegisterNumber(start)) : (getRegisterNumber(start)));
      }
      else {
        throw new Error('Register expected');
      }
      if (isAddressRegisterIdentifier(end)) {
        endBitIndex = (reverse ? (7 - getRegisterNumber(end)) : (getRegisterNumber(end) + 8));
      }
      else if (isDataRegisterIdentifier(end)) {
        endBitIndex = (reverse ? (15 - getRegisterNumber(end)) : (getRegisterNumber(end)));
      }
      else {
        throw new Error('Register expected');
      }

      for (let i = startBitIndex; i <= endBitIndex; i++) {
        mask |= 1 << i;
      }
    }
  }

  return mask;
}

export function encode(instructionNode: ASTInstructionNode, program: Program, block: Block, offset: number) {
  const {mnemonic, size: operandSize} = instructionNode;

  if (!instructions[mnemonic]) {
    // console.log(JSON.stringify(instructionNode));
    // console.log(JSON.stringify(block, undefined, 2));
    throw new Error(`Can't encode unknown instruction: ${mnemonic} ${JSON.stringify(instructionNode)}`);
  }

  const instruction = instructions[mnemonic];
  let size = operandSize ? operandSize : (instruction.defaultSize || 0);

  let encoded = undefined;
  if (instruction.encoder) {
    encoded = instruction.encoder(instructionNode, program, block, offset);
  }

  if (Array.isArray(encoded)) {
    return encoded;
  }

  if (instruction.arguments !== undefined) {
    assert(instructionNode.arguments.length === instruction.arguments, `expected ${instruction.arguments} arguments, got ${instructionNode.arguments.length}`);
  }

  let args = [...instructionNode.arguments];

  let instructionWord = encoded;

  const extensionBytes: number[] = [];

  const registerListArguments = args.filter(arg => arg.type === NodeType.RegisterList);
  let mainArgument = 0;
  let destinationArgument = 1;

  if (!instructionWord) {
    if (instruction.sizes !== undefined) {
      if (!(instruction.sizes & size)) {
        throw new Error(`${size} is not a valid size for ${mnemonic}`);
      }
    }
    else if (instruction.size !== undefined) {
      size = instruction.size;
    }

    instructionWord = instruction.format || 0;

    if (instruction.sizeOffset !== undefined) {
      switch (instruction.sizeType) {
        case SizeType.Byte:
          instructionWord |= operandSizeBitsByte[size] << (instruction.sizeOffset);
          break;
        case SizeType.Alternate:
          instructionWord |= operandSizeBitsAlt[size] << (instruction.sizeOffset - 1);
          break;
        case SizeType.Default:
        default:
          instructionWord |= operandSizeBits[size] << (instruction.sizeOffset - 1);
      }
    }

    if (instruction.opmodeOffset !== undefined) {
      const secondIsData = isIdentifier(instructionNode.arguments[1]) && isDataRegisterIdentifier(instructionNode.arguments[1]);

      let opmode;
      if (instruction.opmodeShort) {
        opmode = (size === OperandSize.Long ? 0b111 : 0b011);
      }
      else {
        opmode = operandSizeBits[size] | ((instruction.opmodeSwapped ? (secondIsData ? 1 : 0) : (secondIsData ? 0 : 1)) << 2);
      }

      instructionWord |= opmode << (instruction.opmodeOffset - 2);
    }

    if (registerListArguments.length) {
      assert(instruction.directionOffset !== undefined, `instruction ${instruction.mnemonic} accepting a register list must have a directionOffset`);

      let registerListIndex = isRegisterList(instructionNode.arguments[0]) ? 0 : 1;
      let nonRegisterListIndex = registerListIndex === 0 ? 1 : 0;
      if (registerListIndex === 0) {
        mainArgument = 1;
        destinationArgument = 0;
      }

      const reverse = asIndirect(instructionNode.arguments[nonRegisterListIndex]).predecrement !== undefined;

      instructionWord |= registerListIndex << (instruction.directionOffset!);

      const registerListMask = getRegisterListMask(registerListArguments[0] as ASTRegisterListNode, reverse);

      extensionBytes.push(...encodeValue(registerListMask, OperandSize.Word));
    }

    if (instruction.effectiveAddressOffset !== undefined) {
      instructionWord |= getEffectiveAddress(args[mainArgument]) << (instruction.effectiveAddressOffset - 5);
    }

    if (instruction.destinationEffectiveAddressOffset !== undefined) {
      let effectiveAddress = getEffectiveAddress(args[destinationArgument]);

      if (instruction.destinationEffectiveAddressSwapped) {
        effectiveAddress = ((effectiveAddress & 0b111000) >> 3) | ((effectiveAddress & 0b111) << 3);
      }

      instructionWord |= effectiveAddress << (instruction.destinationEffectiveAddressOffset - 5);
    }

    if (instruction.destinationRegisterOffset !== undefined) {
      const destinationArg = asIdentifier(args.pop()!);

      assert(isAddressRegisterIdentifier(destinationArg) || isDataRegisterIdentifier(destinationArg), 'destination argument must be a register');

      const destinationRegister = getRegisterNumber(destinationArg);

      instructionWord |= destinationRegister << (instruction.destinationRegisterOffset - 2);
    }

    if (instruction.sourceRegisterOffset !== undefined) {

      const sourceArg = args[0];

      let sourceRegister = 0;

      if (isIdentifier(sourceArg)) {
        assert(isAddressRegisterIdentifier(sourceArg) || isDataRegisterIdentifier(sourceArg), 'source argument must be a register');

        sourceRegister = getRegisterNumber(sourceArg);

        instructionWord |= sourceRegister << (instruction.sourceRegisterOffset - 2);
      }
      else if (isImmediate(sourceArg)) {
        sourceRegister = 0b100;

        if (!instruction.sourceRegisterIsImmediateOffset) {
          throw new Error(`instruction ${mnemonic} needs sourceRegisterIsImmediateOffset to support an immediate in this argument`);
        }

        instructionWord |= sourceRegister << (instruction.sourceRegisterIsImmediateOffset - 2);
      }
    }
  }

  for (let arg = 0; arg < args.length; arg++) {
    const operand = args[arg];

    const addressingMode = getAddressingMode(operand, size);

    if (addressingMode === AddressingMode.None) {
      continue;
    }

    if (instruction.addressingModes) {
      assert(instruction.addressingModes[arg] & addressingMode, `${AddressingMode[addressingMode]} is not a valid addressing mode for argument ${arg} of ${mnemonic}: ${JSON.stringify(operand)}`);
    }

    if (size === OperandSize.Short && arg === 0) {
      instructionWord |= encodeValue(asNumber(program.evaluate(operand, block)).value - (instruction.relativeTarget ? (offset + 2) : 0), OperandSize.Short, instruction.signedTarget)[0];
    }
    else {
      switch (addressingMode) {
        case AddressingMode.Immediate:
          try {
            extensionBytes.push(...encodeValue(asNumber(program.evaluate(operand, block)).value - (instruction.relativeTarget ? (offset + 2) : 0), size, instruction.signedTarget));
          }
          catch (e) {
            console.log(JSON.stringify(instructionNode, undefined, 2));
            throw e;
          }
          break;
        case AddressingMode.AddressRegisterIndirectIndexDisplacement:
        case AddressingMode.ProgramCounterIndirectIndexDisplacement:
          const indirectIndexDisplacementOp = asIndirect(operand);
          let extensionWord = 0;
          const index = asIdentifier(indirectIndexDisplacementOp.index!);
          if (isAddressRegisterIdentifier(index)) {
            extensionWord |= 1 << 15;
          }
          extensionWord |= getRegisterNumber(index) << 12;
          if (indirectIndexDisplacementOp.indexSize === OperandSize.Long) {
            extensionWord |= 1 << 11;
          }

          const indirectIndexDisplacement = asNumber(program.evaluate(indirectIndexDisplacementOp.displacement!, block)).value - (addressingMode === AddressingMode.ProgramCounterIndirectIndexDisplacement ? (offset + 2) : 0)
          extensionWord |= encodeShort(indirectIndexDisplacement)[0];
          extensionBytes.push((extensionWord & 0xff00) >> 8, extensionWord & 0xff);
          break;
        case AddressingMode.AddressRegisterIndirectDisplacement:
        case AddressingMode.ProgramCounterIndirectDisplacement:
          const indirectDisplacementOp = asIndirect(operand);
          const indirectDisplacement = asNumber(program.evaluate(indirectDisplacementOp.displacement!, block)).value - (addressingMode === AddressingMode.ProgramCounterIndirectDisplacement ? (offset + 2) : 0)

          extensionBytes.push(...encodeValue(indirectDisplacement, OperandSize.Word));
          break;
        case AddressingMode.AbsoluteLong:
        case AddressingMode.AbsoluteShort:
          let absSize = size;

          if (isAbsolute(operand)) {
            absSize = operand.size;
          }
          else if (instruction.sizeOverridesAbsolute) {
            absSize = instructionNode.size || instruction.size || instruction.defaultSize || OperandSize.Long;
          }
          else {
            absSize = instruction.defaultSize || OperandSize.Long;
            // absSize = instructionNode.size || instruction.defaultSize || OperandSize.Long;
          }

          extensionBytes.push(...encodeValue(asNumber(program.evaluate(operand, block)).value - (instruction.relativeTarget ? (offset + 2) : 0), absSize, instruction.signedTarget));

          break;
        default:
          break;
      }
    }
  }

  return [(instructionWord & 0xff00) >> 8, instructionWord & 0xff, ...extensionBytes];
}

function encodeShort(value: number, signed = false) {
  const compl = signed ? (value < 0 ? ((~Math.abs(value + 1) & 0x7F) | 0x80) : value & 0x7f) : value & 0xff;

  return [compl];
}

function encodeByte(value: number, signed = false) {
  const compl = signed ? (value < 0 ? ((~Math.abs(value + 1) & 0x7F) | 0x80) : value & 0x7f) : value & 0xff;

  return [0, compl & 0xff];
}

function encodeWord(value: number, signed = false) {
  const compl = signed ? (value < 0 ? ((~Math.abs(value + 1) & 0x7FFF) | 0x8000) : value & 0x7FFF) : value & 0xFFFF;
  return [(compl & 0xff00) >> 8, compl & 0xff];
}

function encodeLong(value: number, signed = false) {
  const compl = signed ? (value < 0 ? ((~Math.abs(value + 1) & 0x7FFFFFFF) | 0x80000000) : value & 0x7FFFFFFF) : value & 0xFFFFFFFF;
  return [(compl & 0xff000000) >> 24, (compl & 0xff0000) >> 16, (compl & 0xff00) >> 8, compl & 0xff];
}

function encodeValue(value: number, size: OperandSize, signed: boolean = false): number[] {
  if (value < 0) {
    signed = true;
  }
  switch (size) {
    case OperandSize.Short: return encodeShort(value, signed);
    case OperandSize.Byte: return encodeByte(value, signed);
    case OperandSize.Word: return encodeWord(value, signed);
    case OperandSize.Long: return encodeLong(value, signed);
  }

  throw new Error('Invalid size: ' + size);
}

// --------------------------------------------------------
const instructions: Record<string, Instruction> = {};

instructions['dc'] = {
  mnemonic: 'dc',
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  encoder: (instruction: ASTInstructionNode, program: Program, block: Block, offset: number) => {
    const {mnemonic, size: operandSize} = instruction;

    return instruction.arguments.reduce((encoded, arg) => {
      const value = program.evaluate(arg, block);

      if (isNumber(value)) {
        encoded.push(...encodeValue(value.value, operandSize === OperandSize.Byte ? OperandSize.Short : operandSize))
      }
      else if (isString(value)) {
        const str = value.value;
        const stringBytes = [];

        for (let j = 0; j < str.length; j++) {
          stringBytes.push(str.charCodeAt(j));
        }

        if (block.table) {
          encoded.push(...block.table.encode(stringBytes));
        }
        else {
          encoded.push(...stringBytes);
        }
      }

      return encoded;
    }, [] as number[]);
  }
};

instructions['.align'] = {
  mnemonic: '.align',
  encoder: (instruction: ASTInstructionNode, program: Program, block: Block, offset: number) => {
    const {mnemonic, size: operandSize} = instruction;
    const alignment = asNumber(program.evaluate(instruction.arguments[0], block)).value;

    const padding = alignment - (offset % alignment);

    return Array(padding).fill(0);
  }
};

instructions['.print'] = {
  mnemonic: '.print',
  encoder: (instruction: ASTInstructionNode, program: Program, block: Block, offset: number) => {
    if (program.complainMissingVariables) {
      const {mnemonic, size: operandSize} = instruction;
      const args = instruction.arguments.map(arg => {
        const value = program.evaluate(arg, block);
        if (isString(value)) {
          return `"${value.value}"`;
        }
        else {
          return `$${value.value.toString(16).padStart(8, '0')}`;
        }
      });
      console.log(args.join(' '));
    }
    return [];
  }
}

instructions['.incbin'] = {
  mnemonic: '.incbin',
  encoder: (instruction: ASTInstructionNode, program: Program, block: Block, offset: number) => {
    const {mnemonic, size: operandSize} = instruction;
    const file = asString(program.evaluate(instruction.arguments[0], block)).value;
    return [...readFileSync(resolve(dirname(instruction.path), file))];
  }
};

instructions['ds'] = {
  mnemonic: 'ds',
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  encoder: (instruction: ASTInstructionNode, program: Program, block: Block, offset: number) => {
    const {mnemonic, size: operandSize} = instruction;

    const byteSize = operandByteSizes[operandSize];
    const count = asNumber(program.evaluate(instruction.arguments[0], block)).value;

    const fillBytes =  instruction.arguments.length > 1
    ? instruction.arguments.slice(1).map((arg) => {
        return encodeValue(asNumber(program.evaluate(arg, block)).value, operandSize, false)
      }).flat()
    : [0];
      // console.log(Math.ceil((count * byteSize) / fillBytes.length));
    const bytes = Array(Math.ceil((count * byteSize) / fillBytes.length)).fill(fillBytes).flat();

    return bytes.slice(0, count * byteSize);
  }
};

instructions['nop'] = {
  mnemonic: 'nop',
  format: 0x4E71,
  arguments: 0,
  addressingModes: []
};

instructions['move'] = {
  mnemonic: 'move',
  format: 0b00000000_00000000,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement |
    AddressingMode.AbsoluteShort |
    AddressingMode.AbsoluteLong |
    AddressingMode.Immediate,

    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteShort |
    AddressingMode.AbsoluteLong
  ],
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  defaultSize: OperandSize.Word,
  sizeOffset: 13,
  sizeType: SizeType.Alternate,
  effectiveAddressOffset: 5,
  destinationEffectiveAddressOffset: 11,
  destinationEffectiveAddressSwapped: true,
  encoder: (instruction: ASTInstructionNode, program: Program, block: Block, offset: number) => {
    assert(instruction.arguments.length === 2);

    const first = instruction.arguments[0];
    const second = instruction.arguments[1];
    const firstIsIdentifier = isIdentifier(first);
    const secondIsIdentifier = isIdentifier(second);
    const firstIsUSP = firstIsIdentifier && isUSPRegisterIdentifier(first);
    const secondIsUSP = secondIsIdentifier && isUSPRegisterIdentifier(second);
    const firstIsSR = firstIsIdentifier && isSRRegisterIdentifier(first);
    const secondIsSR = secondIsIdentifier && isSRRegisterIdentifier(second);

    let instructionWord = undefined;

    if (firstIsUSP || secondIsUSP) {
      const regArg = firstIsUSP ? 1 : 0;

      instructionWord = 0b0100_1110_0110_0000 | (regArg << 3) | getRegisterNumber(asIdentifier(firstIsUSP ? second : first));
    }
    else if (firstIsSR) {
      instructionWord = 0b0100_0000_1100_0000 | getEffectiveAddress(second);
    }
    else if (secondIsSR) {
      instructionWord = 0b0100_0110_1100_0000 | getEffectiveAddress(first);
    }

    return instructionWord;
  }
}

instructions['movem'] = {
  mnemonic: 'movem',
  format: 0b01001000_10000000,
  arguments: 2,
  addressingModes: [
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.RegisterList,

    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.RegisterList
  ],
  sizes: OperandSize.Word | OperandSize.Long,
  sizeOffset: 6,
  sizeType: SizeType.Byte,
  directionOffset: 10,
  effectiveAddressOffset: 5
}

instructions['moveq'] = {
  mnemonic: 'moveq',
  format: 0b0111_0000_0000_0000,
  arguments: 2,
  addressingModes: [
    AddressingMode.Immediate,
    AddressingMode.DataRegisterDirect
  ],
  size: OperandSize.Short,
  destinationRegisterOffset: 11
};

instructions['movea'] = {
  mnemonic: 'movea',
  format: 0b0000_0000_0100_0000,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,
    AddressingMode.AddressRegisterDirect
  ],
  sizes: OperandSize.Word | OperandSize.Long,
  sizeOffset: 13,
  sizeType: SizeType.Alternate,
  destinationRegisterOffset: 11,
  effectiveAddressOffset: 5
};

instructions['bra'] = {
  mnemonic: 'bra',
  format: 0b01100000_00000000,
  arguments: 1,
  addressingModes: [AddressingMode.AbsoluteLong],
  sizes: OperandSize.Short | OperandSize.Word,
  defaultSize: OperandSize.Short,
  relativeTarget: true,
  signedTarget: true,
}

instructions['jsr'] = {
  mnemonic: 'jsr',
  format: 0b0100_1110_1000_0000,
  arguments: 1,
  addressingModes: [
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteShort |
    AddressingMode.AbsoluteLong |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ],
  effectiveAddressOffset: 5,
  size: OperandSize.Long,
  unsized: true
};

instructions['jmp'] = {
  mnemonic: 'jmp',
  format: 0b0100_1110_1100_0000,
  arguments: 1,
  addressingModes: [
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteShort |
    AddressingMode.AbsoluteLong |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ],
  size: OperandSize.Long,
  unsized: true,
  effectiveAddressOffset: 5
};

for (const conditionalType of validBranchConditionalBits as ConditionalType[]) {
  const mnemonic = `b${conditionalType.toLowerCase()}`;
  instructions[mnemonic] = {
    mnemonic,
    format: 0b01100000_00000000 | ((conditionalBits[conditionalType] || 0) << 8),
    arguments: 1,
    addressingModes: [AddressingMode.AbsoluteLong],
    sizes: OperandSize.Short | OperandSize.Word,
    relativeTarget: true,
    defaultSize: OperandSize.Short,
    sizeOverridesAbsolute: true
    // overrideAbsoluteSize: OperandSize.Short
  };
}

for (const conditionalType of validTestDecrementBranchConditionalBits as ConditionalType[]) {
  const mnemonic = `db${conditionalType.toLowerCase()}`;
  instructions[mnemonic] = {
    mnemonic,
    format: 0b0101_0000_1100_1000 | ((conditionalBits[conditionalType] || 0) << 8),
    arguments: 2,
    addressingModes: [AddressingMode.DataRegisterDirect, AddressingMode.AbsoluteLong],
    size: OperandSize.Word,
    relativeTarget: true,
    sourceRegisterOffset: 2,
    defaultSize: OperandSize.Word
  };
}

instructions['dbra'] = instructions['dbf'];

instructions['lea'] = {
  mnemonic: 'lea',
  format: 0b01000001_11000000,
  effectiveAddressOffset: 5,
  destinationRegisterOffset: 11,
  arguments: 2,
  addressingModes: [
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,
    AddressingMode.AddressRegisterDirect,
  ],
  size: OperandSize.Long
}

instructions['cmpi'] = {
  mnemonic: 'cmpi',
  format: 0b0000_1100_0000_0000,
  sizeOffset: 7,
  destinationEffectiveAddressOffset: 5,
  arguments: 2,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  addressingModes: [
    AddressingMode.Immediate,

    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort
  ]
};

instructions['tst'] = {
  mnemonic: 'tst',
  format: 0b01001010_00000000,
  sizeOffset: 7,
  effectiveAddressOffset: 5,

  arguments: 1,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  sizeType: SizeType.Default,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ]
}

instructions['add'] = {
  mnemonic: 'add',
  format: 0b1101_0000_0000_0000,
  opmodeOffset: 8,
  effectiveAddressOffset: 5,
  destinationRegisterOffset: 11,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ]
}

instructions['adda'] = {
  mnemonic: 'adda',
  format: 0b1101_0000_0000_0000,
  opmodeOffset: 8,
  opmodeShort: true,
  effectiveAddressOffset: 5,
  destinationRegisterOffset: 11,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ]
}

instructions['sub'] = {
  mnemonic: 'sub',
  format: 0b1001_0000_0000_0000,
  opmodeOffset: 8,
  opmodeSwapped: false,
  effectiveAddressOffset: 5,
  destinationRegisterOffset: 11,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ]
}

instructions['subi'] = {
  mnemonic: 'subi',
  format: 0b0000_0100_0000_0000,
  sizeOffset: 7,
  destinationEffectiveAddressOffset: 5,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.Immediate,

    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort
  ]
}

instructions['suba'] = {
  mnemonic: 'suba',
  format: 0b1001_0000_0000_0000,
  opmodeOffset: 8,
  opmodeShort: true,
  effectiveAddressOffset: 5,
  destinationRegisterOffset: 11,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ]
}

instructions['or'] = {
  mnemonic: 'or',
  format: 0b1000_0000_0000_0000,
  opmodeOffset: 8,
  effectiveAddressOffset: 5,
  destinationRegisterOffset: 11,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ]
}

instructions['and'] = {
  mnemonic: 'and',
  format: 0b1100_0000_0000_0000,
  opmodeOffset: 8,
  effectiveAddressOffset: 5,
  destinationRegisterOffset: 11,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ]
}

instructions['mulu'] = {
  mnemonic: 'mulu',
  format: 0b1100_0000_1100_0000,
  effectiveAddressOffset: 5,
  destinationRegisterOffset: 11,
  sizes: OperandSize.Word,
  defaultSize: OperandSize.Word,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,

    AddressingMode.DataRegisterDirect
  ]
}

instructions['divu'] = {
  mnemonic: 'divu',
  format: 0b1000_0000_1100_0000,
  effectiveAddressOffset: 5,
  destinationRegisterOffset: 11,
  sizes: OperandSize.Word,
  defaultSize: OperandSize.Word,
  arguments: 2,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,

    AddressingMode.DataRegisterDirect
  ]
}

instructions['andi'] = {
  mnemonic: 'andi',
  format: 0b0000_0010_0000_0000,
  sizeOffset: 7,
  destinationEffectiveAddressOffset: 5,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.Immediate,

    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort
  ]
}

instructions['ori'] = {
  mnemonic: 'ori',
  format: 0b0000_0000_0000_0000,
  sizeOffset: 7,
  destinationEffectiveAddressOffset: 5,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.Immediate,

    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort
  ]
}

instructions['addi'] = {
  mnemonic: 'addi',
  format: 0b0000_0110_0000_0000,
  sizeOffset: 7,
  destinationEffectiveAddressOffset: 5,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  arguments: 2,
  addressingModes: [
    AddressingMode.Immediate,

    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort
  ]
}

instructions['clr'] = {
  mnemonic: 'clr',
  format: 0b0100_0010_0000_0000,
  arguments: 1,
  effectiveAddressOffset: 5,
  sizeOffset: 7,
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  defaultSize: OperandSize.Long,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort
  ]
}

instructions['btst'] = {
  mnemonic: 'btst',
  format: 0b0000_0001_0000_0000,
  destinationEffectiveAddressOffset: 5,
  arguments: 2,
  sizes: OperandSize.Byte | OperandSize.Long,
  addressingModes: [
    AddressingMode.DataRegisterDirect | AddressingMode.Immediate,

    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement,
    AddressingMode.DataRegisterDirect |
    AddressingMode.AddressRegisterDirect |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort |
    AddressingMode.Immediate |
    AddressingMode.ProgramCounterIndirectDisplacement |
    AddressingMode.ProgramCounterIndirectIndexDisplacement
  ],
  defaultSize: OperandSize.Word,
  sourceRegisterOffset: 11,
  sourceRegisterIsImmediateOffset: 11,
  encoder (instruction, program, block, offset) {
    if (isImmediate(instruction.arguments[0])) {
      return 0b0000_1000_0000_0000 | getEffectiveAddress(instruction.arguments[1]);
    }
    else {
      return 0b0000_0001_0000_0000 | getEffectiveAddress(instruction.arguments[1]);
    }
  },
};


instructions['lsr'] = {
  mnemonic: 'lsr',
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.Immediate |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort,

    AddressingMode.DataRegisterDirect
  ],
  encoder: (instruction: ASTInstructionNode, program: Program, block: Block, offset: number) => {
    let instructionWord = 0;

    if (instruction.arguments.length === 1) {
      instructionWord = 0b1110_0010_1100_0000 | getEffectiveAddress(instruction.arguments[0]);
    }
    else {
      if (isImmediate(instruction.arguments[0])) {
        let shiftCount = asNumber(program.evaluate(instruction.arguments[0], block)).value;
        if (shiftCount === 8) {
          shiftCount = 0;
        }
        instructionWord = 0b1110_0000_0000_1000 |
          ((shiftCount & 0b111) << 9) |
          operandSizeBits[instruction.size] << 6 |
          getRegisterNumber(asIdentifier(instruction.arguments[1]));
      }
      else {
        instructionWord = 0b1110_0000_0000_1000 |
          (getRegisterNumber(asIdentifier(instruction.arguments[0])) << 9) |
          operandSizeBits[instruction.size] << 6 |
          1 << 5 |
          getRegisterNumber(asIdentifier(instruction.arguments[1]));
      }
    }

    return [(instructionWord & 0xff00) >> 8, instructionWord & 0xff];
  }
}

instructions['lsl'] = {
  mnemonic: 'lsl',
  sizes: OperandSize.Byte | OperandSize.Word | OperandSize.Long,
  addressingModes: [
    AddressingMode.DataRegisterDirect |
    AddressingMode.Immediate |
    AddressingMode.AddressRegisterIndirect |
    AddressingMode.AddressRegisterIndirectPostIncrement |
    AddressingMode.AddressRegisterIndirectPreDecrement |
    AddressingMode.AddressRegisterIndirectDisplacement |
    AddressingMode.AddressRegisterIndirectIndexDisplacement |
    AddressingMode.AbsoluteLong |
    AddressingMode.AbsoluteShort,

    AddressingMode.DataRegisterDirect
  ],
  encoder: (instruction: ASTInstructionNode, program: Program, block: Block, offset: number) => {
    let instructionWord = 0;

    if (instruction.arguments.length === 1) {
      instructionWord = 0b1110_0011_1100_0000 | getEffectiveAddress(instruction.arguments[0]);
    }
    else {
      if (isImmediate(instruction.arguments[0])) {
        let shiftCount = asNumber(program.evaluate(instruction.arguments[0], block)).value;
        if (shiftCount === 8) {
          shiftCount = 0;
        }
        instructionWord = 0b1110_0001_0000_1000 |
          ((shiftCount & 0b111) << 9) |
          operandSizeBits[instruction.size] << 6 |
          getRegisterNumber(asIdentifier(instruction.arguments[1]));
      }
      else {
        instructionWord = 0b1110_0001_0000_1000 |
          (getRegisterNumber(asIdentifier(instruction.arguments[0])) << 9) |
          operandSizeBits[instruction.size] << 6 |
          1 << 5 |
          getRegisterNumber(asIdentifier(instruction.arguments[1]));
      }
    }

    return [(instructionWord & 0xff00) >> 8, instructionWord & 0xff];
  }
}

instructions['rts'] = {
  mnemonic: 'rts',
  format: 0b0100_1110_0111_0101,
  arguments: 0
};

instructions['rte'] = {
  mnemonic: 'rte',
  format: 0b0100_1110_0111_0011,
  arguments: 0
};
