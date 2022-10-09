import { encode, OperandSize } from "../arch/68k/instructions";
import { NodeType, ASTBlockLevelNode, ASTExpressionNode, ASTNumberNode, ASTStringNode, ASTMacroNode, ASTBlockNode, ASTInstructionNode, ASTNode, ASTStatementNode } from "../parser";
import { Bank } from "./bank";
import { Block } from "./block";
import { Macro } from "./macro";
import { Struct } from "./struct";
import { Table } from "./table";
import { createNumber, asNumber, isString, createNumberFromString, isStatement, isIdentifier, isRegister, isLabel, isInstruction } from "./utils";
import { Variable } from "./variable";

export class Program {
  banks: Bank[] = [];
  globals: Record<string, Variable> = {};
  macros: Record<string, Macro> = {};
  tables: Record<string, Table> = {};
  structs: Record<string, Struct> = {};
  romSize: number = 0;
  macroReplacementCount = 0;

  constructor() {

  }

  sortBanks() {
    let romOffset = 0, ramOffset = 0;
    for (const bank of this.banks) {
      const ramOnly = this.evaluate(bank.rom).value !== 1;

      let bankStart, bankRamStart, bankSize;

      if (ramOnly) {
        bankStart = createNumber(0, bank.path);
        bankRamStart = this.evaluate(bank.ram_start);
        bankSize = this.evaluate(bank.size);
      }
      else{
        bankStart = this.evaluate(bank.start);
        bankRamStart = this.evaluate(bank.ram_start);
        bankSize = this.evaluate(bank.size);

        if (bankStart.value === -1) {
          bankStart = createNumber(romOffset, bank.path);
          bank.start = bankStart;
        }
        else {
          romOffset = asNumber(bankStart).value;
        }
      }

      if (bankRamStart.value === -1) {
        bankRamStart = createNumber(ramOffset, bank.path);
        bank.ram_start = bankRamStart;
      }
      else {
        ramOffset = asNumber(bankRamStart).value;
      }

      if (!ramOnly) {
        this.setGlobal(bank.name + '.start', bankStart);
      }
      this.setGlobal(bank.name + '.ram_start', bankRamStart);

      let bankOffset = 0;

      for (const block of bank.blocks) {
        if (block.align !== 1) {
          const offset = (romOffset + bankOffset);

          const pad = (offset % block.align);

          bankOffset += pad === 0 ? 0 : block.align - pad;

        }

        block.codeSize = block.code.reduce((size: number, node: ASTBlockLevelNode) => {
          if (node.type === NodeType.Statement) {
            size += encode(node.instruction, this, block, size + ramOffset + bankOffset).length;
          }
          if (node.type === NodeType.Label) {
            if (node.name.substring(0, 1) === '.') {
              block.setLocal(node.name, createNumber(ramOffset + bankOffset + size, node.path));
            }
            else {
              this.setGlobal(node.name, createNumber(ramOffset + bankOffset + size, node.path));
            }
            console.log(`Label ${node.name} @ ${(ramOffset + bankOffset + size).toString(16).padStart(8, "0")}`);
          }

          return size;
        }, 0);
        block.bankOffset = bankOffset;

        bankOffset += block.codeSize;
      }

      bank.codeSize = bankOffset;

      if (bankSize.value === -1) {
        bankSize = createNumber(bankOffset, bank.path);
        bank.size = bankSize;
      }
      else {
        if (bank.codeSize > bankSize.value) {
          throw new Error(`Bank ${bank.name} code size ${bank.codeSize} is larger than the bank size ${bankSize.value}`);
        }
      }

      this.setGlobal(bank.name + '.size', bankSize);
      this.setGlobal(bank.name + '.end', createNumber(asNumber(bankStart).value + asNumber(bankSize).value, bank.path));

      if (!ramOnly) {
        romOffset += asNumber(bankSize).value;
      }

      ramOffset += asNumber(bankSize).value;
    }

    this.banks = this.banks.sort((a, b) => asNumber(this.evaluate(a.start)).value - asNumber(this.evaluate(b.start)).value);
    this.romSize = romOffset;
  }

  setGlobal(name: string, value: ASTExpressionNode) {
    if (!this.globals[name]) {
      this.globals[name] = new Variable(name);
    }

    this.globals[name].value = value;
  }

  getGlobal(name: string): ASTExpressionNode {
    return this.globals[name]?.value || createNumber(0, '');
  }

  evaluate(node?: ASTExpressionNode, block?: Block): ASTNumberNode | ASTStringNode {
    if (!node) {
      return createNumber(0, '');
    }
    let left;
    switch (node.type) {
      case NodeType.UnaryMinus:
        left = asNumber(this.evaluate(node.value, block));
        left.value = -left.value;
        return left;
      case NodeType.Addition:
        left = asNumber(this.evaluate(node.left, block));
        left.value += asNumber(this.evaluate(node.right, block)).value;
        return left;
      case NodeType.Subtraction:
        left = asNumber(this.evaluate(node.left, block));
        left.value -= asNumber(this.evaluate(node.right, block)).value;
        return left;
      case NodeType.Multiplication:
        left = asNumber(this.evaluate(node.left, block));
        left.value *= asNumber(this.evaluate(node.right, block)).value;
        return left;
      case NodeType.Division:
        left = asNumber(this.evaluate(node.left, block));
        left.value /= asNumber(this.evaluate(node.right, block)).value;
        return left;
      case NodeType.BitwiseOr:
        left = asNumber(this.evaluate(node.left, block));
        left.value |= asNumber(this.evaluate(node.right, block)).value;
        return left;
      case NodeType.BitwiseAnd:
        left = asNumber(this.evaluate(node.left, block));
        left.value &= asNumber(this.evaluate(node.right, block)).value;
        return left;
      case NodeType.LeftShift:
        left = asNumber(this.evaluate(node.left, block));
        left.value <<= asNumber(this.evaluate(node.right, block)).value;
        return left;
      case NodeType.RightShift:
        left = asNumber(this.evaluate(node.left, block));
        left.value >>= asNumber(this.evaluate(node.right, block)).value;
        return left;
      case NodeType.Number: return { ...node };
      case NodeType.Immediate:
      case NodeType.Absolute:
        if (isString(node.value)) {
          return this.evaluate(createNumberFromString(node.value), block);
        }
        else {
          return this.evaluate(node.value, block);
        }
      case NodeType.String: return { ...node };
      case NodeType.Identifier:
        if (node.identifier.substr(0, 1) === '.') {
          if (!block) {
            throw new Error('Local variable not valid here');
          }

          return this.evaluate(block.getLocal(node.identifier), block);
        }
        else {
          return this.evaluate(this.getGlobal(node.identifier), block);
        }

      default:   throw new Error(`Cannot evaluate ${node.type} node statically ${JSON.stringify(node)}`);
    }
  }

  setMacro(name: string, macro: Macro) {
    this.macros[name] = macro;
  }

  getMacro(name: string): Macro | undefined {
    return this.macros[name];
  }

  setTable(name: string, table: Table) {
    this.tables[name] = table;
  }

  getTable(name: string): Table | undefined {
    return this.tables[name];
  }

  setStruct(name: string, struct: Struct) {
    this.structs[name] = struct;
  }

  getStruct(name: string): Struct | undefined {
    return this.structs[name];
  }


  applyMacros(nodes: ASTBlockLevelNode[], block?: Block) {
    return nodes.flatMap((node) => {
      if (isStatement(node)) {
        const macro = this.getMacro(node.instruction.mnemonic);

        if (macro) {
          console.log(`Replacing macro (outer) ${node.instruction.mnemonic}`);
          return this.macroReplace(node, block, macro, node.instruction.size).flat();
        }
      }

      return node;
    }) as ASTBlockLevelNode[];
  }

  macroReplace(statement: ASTStatementNode, block: Block | undefined, macro: Macro, operandSize: OperandSize): ASTBlockLevelNode[] {
    const instruction = statement.instruction;
    console.log(`Replace macro ${instruction.mnemonic}`);
    const macroId = ++this.macroReplacementCount;
    const argumentIndexes = macro.arguments.reduce((r, arg, i) => {
      r[arg] = i;

      return r;
    }, {} as Record<string, number>);

    const result = this.walk(macro.code, block, (node) => {
      if (isIdentifier(node)) {
        if (argumentIndexes[node.identifier] !== undefined) {
          return {...instruction.arguments[argumentIndexes[node.identifier]]};
        }
        else if (node.identifier.substr(0, 1) === '.') {
          return {...node, identifier: this.macroVariableRename(node.identifier, macro.name, macroId)};
        }
      }
      else if (isInstruction(node)) {
        return {...node, size: node.size === OperandSize.MacroArg ? operandSize : node.size};
      }
      else if (isLabel(node)) {
        if (node.name.substr(0, 1) === '.') {
          return {...node, name: this.macroVariableRename(node.name, macro.name, macroId)};
        }
        else {
          throw new Error(`macros cannot define globals (${node.name})`);
        }
      }
      return node;
    }) as ASTBlockLevelNode[];
    console.log(`Applying macros to result of ${instruction.mnemonic} replacement`);
    return this.applyMacros(result.flat()).flat();
  }

  macroVariableRename(name: string, macroName: string, macroId: number) {
    return `.___macro_${macroId}_${macroName}_${name}`;
  }

  walkAll(callback: (node: ASTNode, block: Block) => ASTNode | ASTNode[]) {
    for (const bank of this.banks) {
      for (const block of bank.blocks) {
        block.code = (this.walk(block.code, block, callback as (node: ASTNode, block?: Block) => ASTNode | ASTNode[]) as ASTBlockLevelNode[]).flat();
      }
    }
  }

  walk(node: ASTNode | ASTNode[] | undefined, block: Block | undefined, callback: (node: ASTNode, block?: Block) => ASTNode | ASTNode[]): ASTNode | ASTNode[] | undefined {
    if (Array.isArray(node)) {
      return node.flatMap((arrayNode) => this.walk(arrayNode, block, callback) as ASTNode);
    }

    if (node === undefined) {
      return undefined;
    }

    const astNode = node as ASTNode;

    switch (astNode.type) {
      case NodeType.Statement:
        return callback({ ...astNode, instruction: this.walk(astNode.instruction, block, callback) as unknown as ASTInstructionNode}, block);
      case NodeType.Instruction:
        return callback({ ...astNode, arguments: this.walk(astNode.arguments, block, callback) as unknown as ASTExpressionNode[]}, block);
      case NodeType.Indirect:
        return callback({
          ...astNode,
          value: this.walk(astNode.value, block, callback) as unknown as ASTExpressionNode,
          displacement: this.walk(astNode.displacement, block, callback) as unknown as ASTExpressionNode,
          index: this.walk(astNode.index, block, callback) as unknown as ASTExpressionNode
        }, block);
      case NodeType.Addition:
      case NodeType.Subtraction:
      case NodeType.Multiplication:
      case NodeType.Division:
      case NodeType.LeftShift:
      case NodeType.RightShift:
      case NodeType.BitwiseOr:
      case NodeType.BitwiseAnd:
        return callback({ ...astNode, left: this.walk(astNode.left, block, callback) as ASTExpressionNode, right: this.walk(astNode.right, block, callback) as ASTExpressionNode }, block);
      case NodeType.UnaryMinus:
      case NodeType.Immediate:
      case NodeType.Absolute:
        return callback({ ...astNode, value: this.walk(astNode.value, block, callback) as ASTExpressionNode }, block);
    }

    return callback({ ...astNode }, block);
  }
}
