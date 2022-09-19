import { ASTBlockLevelNode } from "../parser";

export class Block {
  name: string;
  code: ASTBlockLevelNode[] = [];
  bankOffset: number = 0;
  codeSize: number = 0;

  constructor(name: string) {
    this.name = name;
  }
}
