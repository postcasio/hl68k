import { OperandSize } from "../arch/68k/instructions";
import { ASTStructMemberNode } from "../parser";

export class Struct {
  name: string;
  members: Record<string, ASTStructMemberNode>;

  constructor(name: string, members: Record<string, ASTStructMemberNode>) {
    this.name = name;
    this.members = members;
  }
}
