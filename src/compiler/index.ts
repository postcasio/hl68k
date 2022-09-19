import { readFileSync } from "fs";
import { HL68kParser, ASTUnitNode } from "../parser";
import { InitPass } from "./init-pass";
import { OutputPass } from "./output-pass";

export class Compiler {
  // tree: ASTUnitNode;

  constructor() {
    // this.tree = this.loader(path);
  }

  parse(text: string, path?: string) {
    const parser = new HL68kParser();
    return parser.parse(text, { path });
  }

  compile(path: string, output: string) {
    const tree = this.loader(path);
    //process.stdout.write(JSON.stringify(tree, undefined, 2));
    const initPass = new InitPass();
    const program = initPass.prepareProgram(tree, this);
    program.sortBanks();
    const outputPass = new OutputPass(output, program, this);
    outputPass.write();
    return program;
  }

  loader(path: string) {
    return this.parse(readFileSync(path, { encoding: 'utf-8'}), path);
  }
}
