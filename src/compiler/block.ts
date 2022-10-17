import { ASTBlockLevelNode, ASTExpressionNode } from "../parser";
import { Table } from "./table";
import { createNumber } from "./utils";
import { Variable } from "./variable";

export class Block {
  name: string;
  code: ASTBlockLevelNode[] = [];
  bankOffset: number = 0;
  codeSize: number = 0;
  locals: Record<string, Variable> = {};
  align: number = 1;
  table?: Table;

  constructor(name: string) {
    this.name = name;
  }

  setLocal(name: string, value: ASTExpressionNode) {
    if (!this.locals[name]) {
      this.locals[name] = new Variable(name);
    }

    this.locals[name].value = value;
  }

  getLocal(name: string, throwIfMissing = false): ASTExpressionNode {
    if (throwIfMissing && !this.locals[name]) {
      throw new Error(`${name} is not defined`);
    }

    return this.locals[name]?.value || createNumber(0, '');
  }
}
