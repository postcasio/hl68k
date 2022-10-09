import { OperandSize } from "../arch/68k/instructions";
import { ASTNode, NodeType } from "../parser";
import { Program } from "./program";
import { createNumber } from "./utils";

export function getStructMemberOperandSize(type: string) {
  switch (type.toLowerCase()) {
    case 'byte':
      return OperandSize.Byte;
    case 'word':
      return OperandSize.Word;
    case 'long':
      return OperandSize.Long;
  }

  throw new Error(`Struct members must be \`byte\`, \`word\` or \`long\`, not \`${type}\``)
}

export class MacroTransformPass {
  transform(program: Program) {
    for (const bank of program.banks) {
      console.log(`Apply macros to bank ${bank.name}`);
      for (const block of bank.blocks) {
          console.log(`Apply macros to block ${block.name}`);
          block.code = program.applyMacros(block.code, block);
      }
    };
  }
}
