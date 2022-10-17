import { dirname, resolve } from "path";
import { Compiler } from ".";
import { OperandSize } from "../arch/68k/instructions";
import { NodeType, ASTNode, ASTUnitNode, ASTInstructionNode, ASTMacroNode, ASTBlockLevelNode, ASTExpressionNode, ASTStatementNode } from "../parser";
import { Bank } from "./bank";
import { Block } from "./block";
import { Macro } from "./macro";
import { Program } from "./program";
import { Struct } from "./struct";
import { encodeTableBytes, Table } from "./table";
import { asIdentifier, asNumber, calculateCodeSize, createNumber, isIdentifier, isIndirect, isInstruction, isStatement } from "./utils";


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
              case 'align': bank.align = property.value; break;
            }
          }

          if (!ram_start_defined) {
            bank.ram_start = bank.start;
          }

          program.banks.push(bank);

          break;
        case NodeType.Macro:
          const macro = new Macro(node.name);
          macro.arguments = node.arguments;
          macro.code = node.code;
          program.setMacro(node.name, macro);

          break;
        case NodeType.Table:
          const table = new Table(node.name, node.entries.map(entry => ({
            left: encodeTableBytes(entry.left, program),
            right: encodeTableBytes(entry.right, program)
          })));

          program.setTable(node.name, table);
          break;
        case NodeType.Struct:
          const struct = new Struct(node.name, node.members);
          program.setStruct(node.name, struct);
          let structMemberOffset = 0;
          for (let [name, def] of Object.entries(struct.members)) {
            program.setGlobal(`${node.name}.${name}`, createNumber(structMemberOffset, node.path));
            switch (def.operandSize) {
              case OperandSize.Byte:
                structMemberOffset += 1 * asNumber(program.evaluate(def.count)).value;
                break;
              case OperandSize.Word:
                structMemberOffset += 2 * asNumber(program.evaluate(def.count)).value;
                break;
              case OperandSize.Long:
                structMemberOffset += 4 * asNumber(program.evaluate(def.count)).value;
                break;
            }
          }
          program.setGlobal(`${node.name}.$size`, createNumber(structMemberOffset, node.path));
          break;
        case NodeType.Block:
          const block = new Block(node.name);
          let blockBankName: string = '<no name>';
          let blockAlign = 2;
          let blockTable;
          for (const property of node.properties) {
            switch (property.name) {
              case 'bank': blockBankName = asIdentifier(property.value).identifier; break;
              case 'align': blockAlign = asNumber(program.evaluate(property.value)).value; break;
              case 'table': blockTable = asIdentifier(property.value).identifier; break;
            }
          }

          block.code = node.code;
          block.align = blockAlign;
          if (blockTable) {
            block.table = program.getTable(blockTable);
          }

          const blockBank = program.banks.find(bank => bank.name === blockBankName);

          if (!blockBank) {
            throw new Error(`Bank ${blockBankName} does not exist ${JSON.stringify(node)}`);
          }

          blockBank.blocks.push(block);
      }
    }

    return program;
  }


}
