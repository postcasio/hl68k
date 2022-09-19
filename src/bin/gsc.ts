import { HL68kParser } from "../parser";
import { readFileSync } from 'fs';
import { Compiler } from "../compiler";


const compiler = new Compiler();

compiler.compile(process.argv[2], process.argv[3]);
// console.log(JSON.stringify(program, undefined, '  '));
