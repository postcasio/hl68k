import { readFileSync } from "fs";
import { HL68kParser, ASTUnitNode } from "../parser";
import { InitPass } from "./init-pass";
import { MacroTransformPass } from "./macro-transform-pass";
import { OutputPass } from "./output-pass";
import { StructTransformPass } from "./struct-transform-pass";

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

    const initPass = new InitPass();
    const program = initPass.prepareProgram(tree, this);
    const macroTransformPass = new MacroTransformPass();
    macroTransformPass.transform(program);
    const structTransformPass = new StructTransformPass();
    structTransformPass.transform(program);
    program.sortBanks();
    const outputPass = new OutputPass(output, program, this);
    outputPass.write();
    // process.stdout.write(JSON.stringify(program, undefined, 2));
    return program;
  }

  loader(path: string) {
    return this.parse(readFileSync(path, { encoding: 'utf-8'}), path);
  }
}
