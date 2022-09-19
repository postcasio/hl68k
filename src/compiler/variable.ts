import { ASTExpressionNode } from "../parser";
import { createNumber } from "./utils";

export class Variable {
  name: string;
  value: ASTExpressionNode = createNumber(0, '<?>');

  constructor(name: string) {
    this.name = name;
  }
}
