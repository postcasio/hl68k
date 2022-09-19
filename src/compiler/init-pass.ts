import { dirname, resolve } from "path";
import { Compiler } from ".";
import { NodeType, ASTNode, ASTUnitNode, ASTInstructionNode, ASTMacroNode, ASTBlockLevelNode, ASTExpressionNode, ASTStatementNode } from "../parser";
import { Bank } from "./bank";
import { Block } from "./block";
import { Program } from "./program";
import { asIdentifier, calculateCodeSize, isIdentifier, isIndirect, isInstruction, isStatement } from "./utils";


export type UnitLoader = (file: string) => ASTUnitNode;

export class InitPass {
  prepareProgram(tree: ASTUnitNode, compiler: Compiler) {
    const program = new Program();

    const nodes = tree.code.slice();

    for (let nodeIndex = 0; nodeIndex < nodes.length; nodeIndex++) {
      const node = nodes[nodeIndex];

      switch (node.type) {
        case NodeType.Assignment:
          program.setGlobal(node.name, node.value);
          break;
        case NodeType.Macro:
          program.setMacro(node.name, node);
          break;
        case NodeType.Include:
          const path = resolve(dirname(node.path), node.file.value);

          const unit = compiler.loader(path);

          for (let includedNodeIndex = 0; includedNodeIndex < unit.code.length; includedNodeIndex++) {
            nodes.splice(nodeIndex + includedNodeIndex + 1, 0, unit.code[includedNodeIndex]);
          }

          break;
        case NodeType.Bank:
          const bank = new Bank(node.name, node.path);
          let ram_start_defined;

          for (const property of node.properties) {
            switch (property.name) {
              case 'name': bank.name = asIdentifier(property.value).identifier; break;
              case 'start': bank.start = property.value; break;
              case 'ram_start': bank.ram_start = property.value; ram_start_defined = true; break;
              case 'size': bank.size = property.value; break;
              case 'rom': bank.rom = property.value; break;
            }
          }

          if (!ram_start_defined) {
            bank.ram_start = bank.start;
          }

          program.banks.push(bank);

          break;
        case NodeType.Block:
          const block = new Block(node.name);
          let blockBankName: string = '<no name>';

          for (const property of node.properties) {
            switch (property.name) {
              case 'bank': blockBankName = asIdentifier(property.value).identifier; break;
            }
          }

          block.code = node.code.flatMap((node) => {
            if (isStatement(node)) {
              const macro = program.getMacro(node.instruction.mnemonic);

              if (macro) {
                return this.macroReplace(node.instruction, macro);
              }
            }

            return node;
          }) as ASTBlockLevelNode[];
          block.codeSize = calculateCodeSize(block.code, program);

          const blockBank = program.banks.find(bank => bank.name === blockBankName);

          if (!blockBank) {
            throw new Error(`Bank ${blockBankName} does not exist`);
          }

          blockBank.blocks.push(block);
      }
    }

    return program;
  }

  macroReplace(instruction: ASTInstructionNode, macro: ASTMacroNode): ASTNode[] {
    const argumentIndexes = macro.arguments.reduce((r, arg, i) => {
      r[arg] = i;

      return r;
    }, {} as Record<string, number>);

    const result = this.walk(macro.code, (node) => {
      if (isIdentifier(node) && argumentIndexes[node.identifier] !== undefined) {
        return {...instruction.arguments[argumentIndexes[node.identifier]]};
      }
      return node;
    }) as ASTNode[];

    return result;
  }

  walk(node: ASTNode | ASTNode[] | undefined, callback: (node: ASTNode) => ASTNode): ASTNode | ASTNode[] | undefined {
    if (Array.isArray(node)) {
      return node.map((arrayNode) => this.walk(arrayNode, callback) as ASTNode);
    }

    if (node === undefined) {
      return undefined;
    }

    const astNode = node as ASTNode;

    switch (astNode.type) {
      case NodeType.Statement:
        return callback({ ...astNode, instruction: this.walk(astNode.instruction, callback) as unknown as ASTInstructionNode});
      case NodeType.Instruction:
        return callback({ ...astNode, arguments: this.walk(astNode.arguments, callback) as unknown as ASTExpressionNode[]});
      case NodeType.Indirect:
        return callback({
          ...astNode,
          value: this.walk(astNode.value, callback) as unknown as ASTExpressionNode,
          displacement: this.walk(astNode.displacement, callback) as unknown as ASTExpressionNode,
          index: this.walk(astNode.index, callback) as unknown as ASTExpressionNode
        });
      case NodeType.Addition:
      case NodeType.Subtraction:
      case NodeType.Multiplication:
      case NodeType.Division:
      case NodeType.LeftShift:
      case NodeType.RightShift:
      case NodeType.BitwiseOr:
        return callback({ ...astNode, left: this.walk(astNode.left, callback) as ASTExpressionNode, right: this.walk(astNode.right, callback) as ASTExpressionNode });
      case NodeType.UnaryMinus:
      case NodeType.Immediate:
      case NodeType.Absolute:
        return callback({ ...astNode, value: this.walk(astNode.value, callback) as ASTExpressionNode });
    }

    return callback({ ...astNode });
  }
}
