import { OperandSize } from "../arch/68k/instructions";
import { ASTBlockLevelNode, ASTNode, ASTRepeatNode, NodeType } from "../parser";
import { Program } from "./program";
import { asNumber, createNumber } from "./utils";

export class RepeatTransformClass {
  transform(program: Program) {
    program.walkAll((node, block) => {
      switch (node.type) {
        case NodeType.Repeat:
          return this.repeat(node, program);
      }

      return node;
    });
  }

  repeat(node: ASTRepeatNode, program: Program): ASTNode[] {
    const repeated: ASTNode[] = [];
    const count = asNumber(program.evaluate(node.count)).value;

    for (let i = 0; i < count; i++) {
      for (const child of node.code) {
        if (child.type === NodeType.Repeat) {
          repeated.push(...this.repeat(child, program));
        }
        else {
          repeated.push({...child});
        }
      }
    }

    return repeated;
  }
}
