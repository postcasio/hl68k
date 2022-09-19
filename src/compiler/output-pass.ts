import { writeFileSync } from "fs";
import { Compiler } from ".";
import { encode } from "../arch/68k/instructions";
import { NodeType, ASTStatementNode } from "../parser";
import { Block } from "./block";
import { Program } from "./program";
import { asNumber } from "./utils";



export class OutputPass {
  program: Program;
  compiler: Compiler;
  path: string;
  // output: DataView;

  constructor(path: string, program: Program, compiler: Compiler) {
    this.path = path;
    this.program = program;
    this.compiler = compiler;
  }

  write() {
    const romBuffer = new Uint8Array(new ArrayBuffer(this.program.romSize));
    let romOffset = 0, ramOffset = 0;

    for (const bank of this.program.banks) {
      // console.log(`Bank ${bank.name} ROM = ${asNumber(this.program.evaluate(bank.rom)).value}`);
      if (asNumber(this.program.evaluate(bank.rom)).value !== 1) {
        continue;
      }

      romOffset = asNumber(this.program.evaluate(bank.start)).value;
      ramOffset = asNumber(this.program.evaluate(bank.ram_start)).value;

      for (const block of bank.blocks) {
        // console.log(`Block ${block.name} at ${romOffset}`);
        const blockBuffer = this.writeBlock(block, ramOffset);
        romBuffer.set(new Uint8Array(blockBuffer), romOffset);
        romOffset += blockBuffer.byteLength;
        ramOffset += blockBuffer.byteLength;
      }
    }

    writeFileSync(this.path, romBuffer);
  }

  writeBlock(block: Block, bankOffset: number): ArrayBuffer {
    const blockBuffer = new ArrayBuffer(block.codeSize);
    const view = new Uint8Array(blockBuffer);

    let offset = 0;

    for (const node of block.code) {
      switch (node.type) {
        case NodeType.Statement:
          const code = this.emit(node, bankOffset + offset);
          view.set(code, offset);
          offset += code.length;
          break;
        case NodeType.Label:
          break;
      }
    }

    return view.buffer;
  }

  size(node: ASTStatementNode) {
    return encode(node.instruction, this.program, 0).length;
  }

  emit(node: ASTStatementNode, offset: number) {
    return encode(node.instruction, this.program, offset);
  }
}
