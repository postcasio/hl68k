import { ASTBlockLevelNode, ASTExpressionNode } from "../parser";
import { Block } from "./block";
import { createNumber } from "./utils";
import { Variable } from "./variable";

export class Macro extends Block {
  arguments: string[] = [];
}
