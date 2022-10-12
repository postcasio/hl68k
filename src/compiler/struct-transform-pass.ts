import { OperandSize } from "../arch/68k/instructions";
import { ASTNode, NodeType } from "../parser";
import { Program } from "./program";
import { asNumber, createNumber } from "./utils";

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

export class StructTransformPass {
  transform(program: Program) {
    program.walkAll((node, block) => {
      switch (node.type) {
        case NodeType.StructInstance:
          const members = node.members;
          const struct = program.getStruct(node.name);
          if (!struct) {
            throw new Error(`Undefined struct ${node.name}`);
          }
          const replacementDefinitions: ASTNode[] = [];
          for (let [name, def] of Object.entries(struct.members)) {
            const size = def.operandSize;
            const expr = members[name] || createNumber(0, node.path);
            const count = asNumber(program.evaluate(def.count)).value;

            replacementDefinitions.push({
              type: NodeType.Statement,
              path: node.path,
              instruction: {
                type: NodeType.Instruction,
                path: node.path,
                mnemonic: 'dc',
                size,
                arguments: Array.isArray(expr) ? expr : Array(count).fill(expr)
              }
            });
          }

          return replacementDefinitions;
      }

      return node;
    });
  }
}
