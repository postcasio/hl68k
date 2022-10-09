import { encode, OperandSize } from "../arch/68k/instructions";
import { NodeType, ASTNode, ASTExpressionNode, ASTIdentifierNode, ASTImmediateNode, ASTIndirectNode, ASTNumberNode, ASTStatementNode, ASTBlockLevelNode, ASTStringNode, ASTAbsoluteNode, ASTRegisterListNode, ASTInstructionNode, ASTLabelNode } from "../parser";
import { Block } from "./block";
import { Program } from "./program";

export function isIdentifier(node: ASTNode): node is ASTIdentifierNode {
  return node.type === NodeType.Identifier;
}

const dataRegisterRe = /^d[0-9]$/i;
const addressRegisterRe = /^a[0-9]$/i;
const pcRegisterRe = /^pc$/i;
const spRegisterRe = /^sp$/i;
const uspRegisterRe = /^usp$/i;
const srRegisterRe = /^sr$/i;

export function isDataRegisterIdentifier(identifier: ASTIdentifierNode) {
  return dataRegisterRe.test(identifier.identifier);
}

export function isAddressRegisterIdentifier(identifier: ASTIdentifierNode) {
  return addressRegisterRe.test(identifier.identifier) || spRegisterRe.test(identifier.identifier);
}

export function isPCRegisterIdentifier(identifier: ASTIdentifierNode) {
  return pcRegisterRe.test(identifier.identifier);
}

export function isUSPRegisterIdentifier(identifier: ASTIdentifierNode) {
  return uspRegisterRe.test(identifier.identifier);
}

export function isSRRegisterIdentifier(identifier: ASTIdentifierNode) {
  return srRegisterRe.test(identifier.identifier);
}

export function isRegister(identifier: ASTIdentifierNode) {
  return identifier.isRegister;
}


export function getRegisterNumber(operand: ASTIdentifierNode) {
  if (operand.identifier === 'sp') {
    return 7;
  }

  return parseInt(operand.identifier.substr(-1), 10);
}


export function isStatement(statement: ASTNode): statement is ASTStatementNode {
  return statement.type === NodeType.Statement;
}

export function isLabel(statement: ASTNode): statement is ASTLabelNode {
  return statement.type === NodeType.Label;
}

export function isInstruction(statement: ASTNode): statement is ASTInstructionNode {
  return statement.type === NodeType.Instruction;
}

export function isIndirect(indirect: ASTExpressionNode): indirect is ASTIndirectNode {
  return indirect.type === NodeType.Indirect;
}

export function isAbsolute(absolute: ASTExpressionNode): absolute is ASTAbsoluteNode {
  return absolute.type === NodeType.Absolute;
}

export function isImmediate(immediate: ASTExpressionNode): immediate is ASTImmediateNode {
  return immediate.type === NodeType.Immediate;
}

export function isRegisterList(list: ASTExpressionNode): list is ASTRegisterListNode {
  return list.type === NodeType.RegisterList;
}

export function isString(str: ASTExpressionNode): str is ASTStringNode {
  return str.type === NodeType.String;
}

export function asIdentifier(node: ASTExpressionNode): ASTIdentifierNode {
  if (!isIdentifier(node)) {
    throw new Error(`node must be an identifier, not ${node.type} ${JSON.stringify(node)}`);
  }

  return node;
}

export function asIndirect(node: ASTExpressionNode): ASTIndirectNode {
  if (!isIndirect(node)) {
    throw new Error('node must be an indirect');
  }

  return node;
}

export function asAbsolute(node: ASTExpressionNode): ASTAbsoluteNode {
  if (!isAbsolute(node)) {
    throw new Error('node must be an absolute, not ' + node.type);
  }

  return node;
}

export function asNumber(node: ASTExpressionNode): ASTNumberNode {
  if (isNumber(node)) {
    return node;
  }

  throw new Error(`Require number`);
}

export function asString(node: ASTExpressionNode): ASTStringNode {
  if (isString(node)) {
    return node;
  }

  throw new Error(`Require string`);
}

export function createNumber(value: number, path: string): ASTNumberNode {
  return { type: NodeType.Number, value, path };
}

export function createNumberFromString(string: ASTStringNode): ASTNumberNode {
  const str = string.value;

  if (![1, 2, 4].includes(str.length)) {
    throw new Error(`Invalid string immediate "${str}": must be 1, 2 or 4 characters`);
  }

  const value = ((str.charCodeAt(0) & 0xFF) << 24) | ((str.charCodeAt(1) & 0xFF) << 16) | ((str.charCodeAt(2) & 0xFF) << 8) | (str.charCodeAt(3) & 0x7F);

  return { type: NodeType.Number, value, path: string.path };
}

export function createBytesFromString(string: ASTStringNode): number[] {
  const str = string.value;
  const bytes = [];

  for (let i = 0; i < str.length; i++) {
    bytes.push(str.charCodeAt(i));
  }

  return bytes;
}

export function isNumber(value: ASTExpressionNode): value is ASTNumberNode {
  return value.type === NodeType.Number;
}

export function calculateCodeSize(nodes: ASTBlockLevelNode[], program: Program, block: Block, offset: number) {
  return nodes.reduce((size: number, node: ASTBlockLevelNode) => {
    if (node.type === NodeType.Statement) {
      size += encode(node.instruction, program, block, offset + size).length;
    }

    return size;
  }, 0);
}
