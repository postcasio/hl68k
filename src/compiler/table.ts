import { ASTExpressionNode, ASTTableEntryNode, NodeType } from "../parser";
import { Program } from "./program";
import { createBytesFromString } from "./utils";

export interface TableEntry {
  left: number[];
  right: number[];
}

export class Table {
  name: string;
  entries: TableEntry[];

  constructor(name: string, entries: TableEntry[]) {
    this.name = name;
    this.entries = entries;
  }

  encode(bytes: number[]) {
    const output = [];
    for (let index = 0; index < bytes.length;) {
      const matching = this.match(bytes, index);

      if (matching) {
        output.push(...matching.right);

        index += matching.left.length;
      }
      else {
        output.push(bytes[index++]);
      }
    }

    return output;
  }

  match(bytes: number[], index: number) {
    for (const entry of this.entries) {
      if (entry.left.every((n, i) => bytes[i + index] === n)) {
        return entry;
      }
    }
  }
}

export function encodeTableBytes(args: ASTExpressionNode[], program: Program) {
  let bytes: number[] = [];
  for (const arg of args) {
    const result = program.evaluate(arg);

    if (result.type === NodeType.String) {
      bytes = bytes.concat(createBytesFromString(result));
    }
    else {
      bytes.push(result.value & 0xFF);
    }
  }
  return bytes;
}
