import { encode } from "../arch/68k/instructions";
import { NodeType, ASTBlockLevelNode, ASTExpressionNode, ASTNumberNode, ASTStringNode, ASTMacroNode } from "../parser";
import { Bank } from "./bank";
import { createNumber, asNumber, isString, createNumberFromString } from "./utils";
import { Variable } from "./variable";

export class Program {
  banks: Bank[] = [];
  globals: Record<string, Variable> = {};
  macros: Record<string, ASTMacroNode> = {};
  romSize: number = 0;

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
        block.codeSize = block.code.reduce((size: number, node: ASTBlockLevelNode) => {
          if (node.type === NodeType.Statement) {
            size += encode(node.instruction, this).length;
          }
          if (node.type === NodeType.Label) {
            if (node.name.substring(0, 1) === '.') {
              console.log('SET BANK-LOCAL VARIABLE');
            }
            else {
              this.setGlobal(node.name, createNumber(ramOffset + bankOffset + size, node.path));
            }
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

  evaluate(node: ASTExpressionNode): ASTNumberNode | ASTStringNode {
    let left;
    switch (node.type) {
      case NodeType.UnaryMinus:
        left = asNumber(this.evaluate(node.value));
        left.value = -left.value;
        return left;
      case NodeType.Addition:
        left = asNumber(this.evaluate(node.left));
        left.value += asNumber(this.evaluate(node.right)).value;
        return left;
      case NodeType.Subtraction:
        left = asNumber(this.evaluate(node.left));
        left.value -= asNumber(this.evaluate(node.right)).value;
        return left;
      case NodeType.Multiplication:
        left = asNumber(this.evaluate(node.left));
        left.value *= asNumber(this.evaluate(node.right)).value;
        return left;
      case NodeType.Division:
        left = asNumber(this.evaluate(node.left));
        left.value /= asNumber(this.evaluate(node.right)).value;
        return left;
      case NodeType.BitwiseOr:
        left = asNumber(this.evaluate(node.left));
        left.value |= asNumber(this.evaluate(node.right)).value;
        return left;
      case NodeType.BitwiseAnd:
        left = asNumber(this.evaluate(node.left));
        left.value &= asNumber(this.evaluate(node.right)).value;
        return left;
      case NodeType.LeftShift:
        left = asNumber(this.evaluate(node.left));
        left.value <<= asNumber(this.evaluate(node.right)).value;
        return left;
      case NodeType.RightShift:
        left = asNumber(this.evaluate(node.left));
        left.value >>= asNumber(this.evaluate(node.right)).value;
        return left;
      case NodeType.Number: return { ...node };
      case NodeType.Immediate:
      case NodeType.Absolute:
        if (isString(node.value)) {
          return this.evaluate(createNumberFromString(node.value));
        }
        else {
          return this.evaluate(node.value);
        }
      case NodeType.String: return { ...node };
      case NodeType.Identifier: return this.evaluate(this.getGlobal(node.identifier));

      default:   throw new Error(`Cannot evaluate ${node.type} node statically ${JSON.stringify(node)}`);
    }
  }

  setMacro(name: string, macro: ASTMacroNode) {
    this.macros[name] = macro;
  }

  getMacro(name: string): ASTMacroNode | undefined {
    return this.macros[name];
  }
}
