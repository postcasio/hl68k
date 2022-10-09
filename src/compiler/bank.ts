import { ASTExpressionNode } from "../parser";
import { Block } from "./block";
import { createNumber } from "./utils";

export class Bank {
  name: string;
  start: ASTExpressionNode = createNumber(-1, '');
  ram_start: ASTExpressionNode = createNumber(-1, '');
  size: ASTExpressionNode = createNumber(-1, '');
  rom: ASTExpressionNode = createNumber(0, '');
  align: ASTExpressionNode = createNumber(1, '');
  codeSize: number = 0;
  path: string;

  blocks: Block[] = [];

  constructor(name: string, path: string) {
    this.name = name;
    this.path = path;
  }
}
