%{
  import { OperandSize, getOperandSize } from '../arch/68k/instructions'
  import { getStructMemberOperandSize } from '../compiler/struct-transform-pass'
  import { createNumber } from '../compiler/utils'

  function hexlify (str: string): string {
    return str.split('').map(ch => '0x' + ch.charCodeAt(0).toString(16)).join(', ')
  }

  function parseNumber(num: string): number {
    num = num.replace('_', '');

    if (num.substr(0, 2) === '0b') {
      return parseInt(num.substr(2), 2);
    }

    if (num.substr(0, 1) === '$') {
      return parseInt(num.substr(1), 16);
    }

    return parseInt(num, 10);
  }

  function parseString(str: string) {
    return JSON.parse(str.replace('\\0', '\\u0000'));
  }

  export interface ASTBlockNode {
    type: NodeType.Block;
    path: string;
    name: string;
    properties: ASTPropertyNode[];
    code: ASTBlockLevelNode[];
  }

  export interface ASTStructNode {
    type: NodeType.Struct;
    path: string;
    name: string;
    members: Record<string, ASTStructMemberNode>;
  }

  export interface ASTStructMemberNode {
    type: NodeType.StructMember;
    operandSize: OperandSize;
    count: ASTExpressionNode;
    path: string;
  }

  export interface ASTStructInstanceNode {
    type: NodeType.StructInstance;
    path: string;
    name: string;
    members: Record<string, ASTExpressionNode[]>;
  }

  export type ASTBlockLevelNode = ASTStatementNode | ASTLabelNode | ASTStructInstanceNode | ASTRepeatNode;

  export interface ASTStatementNode {
    type: NodeType.Statement;
    path: string;
    instruction: ASTInstructionNode;
  }

  export interface ASTInstructionNode {
    type: NodeType.Instruction;
    path: string;
    mnemonic: string;
    size: OperandSize;
    arguments: ASTExpressionNode[];
  }

  export interface ASTPropertyNode {
    type: NodeType.Property;
    path: string;
    name: string;
    value: ASTExpressionNode;
  }

  export interface ASTUnitNode {
    type: NodeType.Unit;
    path: string;
    code: ASTTopLevelBlockNode[];
  }

  export interface ASTIncludeNode {
    type: NodeType.Include;
    path: string;
    file: ASTStringNode;
  }

  export interface ASTStringNode {
    type: NodeType.String;
    path: string;
    value: string;
  }

  export interface ASTBankNode {
    type: NodeType.Bank;
    path: string;
    name: string;
    properties: ASTPropertyNode[];
  }

  export interface ASTAssignmentNode {
    type: NodeType.Assignment;
    path: string;
    name: string;
    value: ASTExpressionNode;
  }

  export interface ASTRegisterListNode {
    type: NodeType.RegisterList;
    path: string;
    registers: (ASTIdentifierNode | ASTRegisterRangeNode)[];
  }

  export interface ASTRegisterRangeNode {
    type: NodeType.RegisterRange;
    path: string;
    start: ASTIdentifierNode;
    end: ASTIdentifierNode;
  }

  export type ASTTopLevelBlockNode = ASTBlockNode | ASTBankNode | ASTAssignmentNode | ASTIncludeNode | ASTMacroNode | ASTTableNode | ASTStructNode;

  export type ASTExpressionNode = ASTIndirectNode | ASTAbsoluteNode | ASTNumberNode | ASTAdditionNode | ASTSubtractionNode | ASTMultiplicationNode | ASTDivisionNode | ASTIdentifierNode | ASTUnaryMinusNode | ASTImmediateNode | ASTStringNode | ASTRegisterListNode | ASTRegisterRangeNode | ASTLeftShiftNode | ASTRightShiftNode | ASTBitwiseOrNode | ASTBitwiseAndNode | ASTBitwiseNotNode;

  export interface ASTAbsoluteNode {
    type: NodeType.Absolute;
    path: string;
    value: ASTExpressionNode;
    size: OperandSize;
  }

  export interface ASTIndirectNode {
    type: NodeType.Indirect;
    path: string;
    value: ASTExpressionNode;
    predecrement?: boolean;
    postincrement?: boolean;
    displacement?: ASTExpressionNode;
    index?: ASTExpressionNode;
    indexSize?: OperandSize;
  }

  export interface ASTNumberNode {
    type: NodeType.Number;
    path: string;
    value: number;
  }

  export interface ASTAdditionNode {
    type: NodeType.Addition;
    path: string;
    left: ASTExpressionNode;
    right: ASTExpressionNode;
  }

  export interface ASTSubtractionNode {
    type: NodeType.Subtraction;
    path: string;
    left: ASTExpressionNode;
    right: ASTExpressionNode;
  }

  export interface ASTLeftShiftNode {
    type: NodeType.LeftShift;
    path: string;
    left: ASTExpressionNode;
    right: ASTExpressionNode;
  }

  export interface ASTRightShiftNode {
    type: NodeType.RightShift;
    path: string;
    left: ASTExpressionNode;
    right: ASTExpressionNode;
  }

  export interface ASTBitwiseOrNode {
    type: NodeType.BitwiseOr;
    path: string;
    left: ASTExpressionNode;
    right: ASTExpressionNode;
  }

  export interface ASTBitwiseAndNode {
    type: NodeType.BitwiseAnd;
    path: string;
    left: ASTExpressionNode;
    right: ASTExpressionNode;
  }

    export interface ASTBitwiseNotNode {
    type: NodeType.BitwiseNot;
    path: string;
    operand: ASTExpressionNode;
  }

  export interface ASTMultiplicationNode {
    type: NodeType.Multiplication;
    path: string;
    left: ASTExpressionNode;
    right: ASTExpressionNode;
  }

  export interface ASTDivisionNode {
    type: NodeType.Division;
    path: string;
    left: ASTExpressionNode;
    right: ASTExpressionNode;
  }

  export interface ASTIdentifierNode {
    type: NodeType.Identifier;
    path: string;
    identifier: string;
    isRegister: boolean;
  }

  export interface ASTUnaryMinusNode {
    type: NodeType.UnaryMinus;
    path: string;
    value: ASTExpressionNode;
  }

  export interface ASTLabelNode {
    type: NodeType.Label;
    path: string;
    name: string;
  }


  export interface ASTImmediateNode {
    type: NodeType.Immediate;
    path?: string;
    value: ASTExpressionNode;
  }

  export interface ASTMacroNode {
    type: NodeType.Macro;
    path: string;
    name: string;
    arguments: string[];
    code: ASTBlockLevelNode[];
  }

  export interface ASTTableNode {
    type: NodeType.Table;
    path: string;
    name: string;
    entries: ASTTableEntryNode[]
  }

  export interface ASTTableEntryNode {
    type: NodeType.TableEntry;
    path: string;
    left: ASTExpressionNode[];
    right: ASTExpressionNode[];
  }

  export interface ASTRepeatNode {
    type: NodeType.Repeat;
    path: string;
    count: ASTExpressionNode;
    code: ASTBlockLevelNode[];
  }

  export type ASTNode = ASTExpressionNode | ASTBlockLevelNode | ASTTopLevelBlockNode | ASTInstructionNode;


  export enum NodeType {
    Block = 'BLOCK',
    Property = 'PROPERTY',
    Identifier = 'IDENTIFIER',
    Number = 'NUMBER',
    Unit = 'UNIT',
    Statement = 'STATEMENT',
    Instruction = 'INSTRUCTION',
    Label = 'LABEL',
    Immediate = 'IMMEDIATE',
    Indirect = 'INDIRECT',
    Addition = 'ADDITION',
    Subtraction = 'SUBTRACTION',
    UnaryMinus = 'UNARY_MINUS',
    Bank = 'BANK',
    Multiplication = 'MULTIPLICATION',
    Division = 'DIVISION',
    Assignment = 'ASSIGNMENT',
    Include = 'INCLUDE',
    String = 'STRING',
    Absolute = 'ABSOLUTE',
    RegisterList = 'REGISTER_LIST',
    RegisterRange = 'REGISTER_RANGE',
    Macro = 'MACRO',
    RightShift = 'RIGHT_SHIFT',
    LeftShift = 'LEFT_SHIFT',
    BitwiseOr = 'BITWISE_OR',
    BitwiseAnd = 'BITWISE_AND',
    BitwiseNot = 'BITWISE_NOT',
    Table = 'TABLE',
    TableEntry = 'TABLE_ENTRY',
    Struct = 'STRUCT',
    StructMember = 'STRUCT_MEMBER',
    StructInstance = 'STRUCT_INSTANCE',
    Repeat = 'REPEAT'
  }
%}

%lex

%options case-insensitive

%%
\"[^"]+\"              return 'STRING'
\;.*\n               return 'NEWLINE'
0b[01][01_]*\b              return 'NUMBER'
\$[0-9A-F][0-9A-F_]*\b          return 'NUMBER'
[0-9][0-9_]*\b               return 'NUMBER'
block\b                return 'BLOCK'
struct\b               return 'STRUCT'
bank\b                 return 'BANK'
include\b              return 'INCLUDE'
macro\b                return 'MACRO'
table\b                return 'TABLE'
repeat\b               return 'REPEAT'
\@[A-Z_.][A-Z_.0-9]+\b return 'PROPERTY'
".b"                   return '.b'
".w"                   return '.w'
".l"                   return '.l'
".$"                   return '.$'
(a\d|d\d|sp|sr|usp|fp|pc)\b return 'REGISTER'
[A-Z_.$][A-Z_.0-9$]*   return 'IDENTIFIER'
","                    return ','
"("                    return '('
")"                    return ')'
"["                    return '['
"]"                    return ']'
"{"                    return '{'
"}"                    return '}'
"="                    return '='
";"                    return ';'
">>"                   return '>>'
"<<"                   return '<<'
":"                    return ':'
"|"                    return '|'
"&"                    return '&'
"#"                    return '#'
"-"                    return '-'
"+"                    return '+'
"*"                    return '*'
"/"                    return '/'
"~"                    return '~'
"@"                    return '@'
"<"                    return '<'
">"                    return '>'
\n                     return 'NEWLINE'
\s+                    if (yy.trace) yy.trace(`Skip whitespace ${hexlify(yytext)}`)
<<EOF>>                return 'EOF'
.                      return 'INVALID'

/lex

%left '+' '-'
%left UMINUS

%start unit

%%

unit
  : newline definition_list EOF { return { type: NodeType.Unit, path: yy.path, code: $2 }; }
  | definition_list EOF { return { type: NodeType.Unit, path: yy.path, code: $1 }; }
  ;

definition_list
  : definition_list definition { $$ = $1.concat([$2]); }
  | definition { $$ = [$1]; }
  ;

definition
  : include
  | assignment
  | macro
  | block
  | bank
  | table
  | struct
  ;

include
  : INCLUDE string newline
    { $$ = { type: NodeType.Include, path: yy.path, file: $2 }; } ;

assignment
  : IDENTIFIER '=' math newline
    { $$ = { type: NodeType.Assignment, name: $1, value: $3 } as ASTAssignmentNode; }
  ;

macro
  : MACRO IDENTIFIER '(' ')' block_body newline
    { $$ = { type: NodeType.Macro, path: yy.path, name: $2, arguments: [], code: $5 } as ASTMacroNode; }
  | MACRO IDENTIFIER '(' macro_argument_list ')' block_body newline
    { $$ = { type: NodeType.Macro, path: yy.path, name: $2, arguments: $4, code: $6 } as ASTMacroNode; }
  ;

block
  : BLOCK IDENTIFIER '(' property_list ')' block_body newline
    { $$ = { type: NodeType.Block, path: yy.path, name: $2, properties: $4, code: $6 }; }
  | BLOCK '(' property_list ')' block_body newline
    { $$ = { type: NodeType.Block, path: yy.path, name: '*anonymous', properties: $3, code: $5 }; }
  ;

block_body
  : '{' newline '}' { $$ = []; }
  | '{' newline stmt_list '}' { $$ = $3; }
  ;

bank
  : BANK IDENTIFIER '{' newline property_stmt_list '}' newline
    { $$ = { type: NodeType.Bank, path: yy.path, name: $2, properties: $5 }; }
  ;

table
  : TABLE IDENTIFIER '{' newline table_entry_list '}' newline
    { $$ = { type: NodeType.Table, path: yy.path, name: $2, entries: $5 }; }
  ;

stmt_list
  : stmt_list stmt { $$ = $1.concat($2); }
  | stmt
  ;

stmt
  : instruction newline
    { $$ = [{ type: NodeType.Statement, instruction: $1, path: yy.path }]; }
  | label instruction newline
    { $$ = [$1, {type: NodeType.Statement, instruction: $2, path: yy.path }]; }
  | struct_instance newline
    { $$ = [$1]; }
  | label struct_instance newline
    { $$ = [$1, $2]; }
  | label newline
    { $$ = [$1]; }
  | REPEAT '(' property_expr ')' block_body newline
    { $$ = [{type: NodeType.Repeat, count: $3, code: $5, path: yy.path }]}
  ;

macro_argument_list
  : macro_argument_list ',' IDENTIFIER { $$ = $1.concat([$3]); }
  | IDENTIFIER { $$ = [$1]; }
  ;

property_list
  : property_list ',' property { $$ = $1.concat([$3]); }
  | property { $$ = [$1]; }
  ;

property_stmt_list
  : property_stmt_list property newline { $$ = $1.concat([$2]); }
  | property newline { $$ = [$1]; }
  ;

property
  : PROPERTY '=' property_expr
    { $$ = { type: NodeType.Property, path: yy.path, name: $1.substr(1), value: $3 }; }
  ;


table_entry_list
  : table_entry_list table_entry newline { $$ = $1.concat([$2]); }
  | table_entry newline { $$ = [$1]; }
  ;

table_entry
  : table_entry_value_list '=' table_entry_value_list
    { $$ = { type: NodeType.TableEntry, path: yy.path, left: $1, right: $3 }; }
  ;

table_entry_value_list
  : table_entry_value_list ',' table_entry_value { $$ = $1.concat([$3]); }
  | table_entry_value { $$ = [$1]; }
  ;

table_entry_value
  : string
  | number
  | identifier
  | '(' math ')' { $$ = $2; }
  ;

register
  : REGISTER
    { $$ = { type: NodeType.Identifier, path: yy.path, identifier: $1, isRegister: true } as ASTIdentifierNode; }
  ;

register_list
  : register_list '/' register_list_expr
    { $$ = {...$1, registers: [...$1.registers, $3] }; }
  | register_list_expr
    { $$ = { type: NodeType.RegisterList, path: yy.path, registers: [$1] }; }
  ;

register_list_expr
  : register '-' register
    { $$ = { type: NodeType.RegisterRange, path: yy.path, start: $1, end: $3 }; }
  | register
    { $$ = $1 }
  ;

instruction
  : IDENTIFIER arguments
    { { const dot = $1.indexOf('.', 1); $$ = { type: NodeType.Instruction, path: yy.path, mnemonic: dot >= 0 ? $1.substr(0, dot) : $1, size: getOperandSize(dot >= 0 ? $1.substr(dot + 1) : undefined), arguments: $2 } as ASTInstructionNode; } }
  | IDENTIFIER
    { { const dot = $1.indexOf('.', 1); $$ = { type: NodeType.Instruction, path: yy.path, mnemonic: dot >= 0 ? $1.substr(0, dot) : $1, size: getOperandSize(dot >= 0 ? $1.substr(dot + 1) : undefined), arguments: [] } as ASTInstructionNode; } }
  ;

struct
  : STRUCT IDENTIFIER struct_body newline
    { $$ = { type: NodeType.Struct, path: yy.path, name: $2, members: Object.fromEntries($3) }; }
  ;

struct_body
  : '{' newline '}' { $$ = []; }
  | '{' newline struct_member_list '}' { $$ = $3; }
  ;

struct_member_list
  : struct_member_list struct_member newline { $$ = $1.concat([$2]); }
  | struct_member newline { $$ = [$1]; }
  ;

struct_member
  : IDENTIFIER IDENTIFIER
    { $$ = [$2, { type: NodeType.StructMember, operandSize: getStructMemberOperandSize($1), count: createNumber(1, yy.path), path: yy.path }]; }
  | IDENTIFIER IDENTIFIER '[' math ']'
    { $$ = [$2, { type: NodeType.StructMember, operandSize: getStructMemberOperandSize($1), count: $4, path: yy.path }]; }
  ;

struct_instance
  : IDENTIFIER '{' newline struct_instance_member_list '}'
    { $$ = { type: NodeType.StructInstance, path: yy.path, name: $1, members: Object.fromEntries($4) }; }
  | IDENTIFIER '{' '}'
    { $$ = { type: NodeType.StructInstance, path: yy.path, name: $1, members: {} }; }
  ;

struct_instance_member_list
  : struct_instance_member_list struct_instance_member newline { $$ = $1.concat([$2]); }
  | struct_instance_member newline { $$ = [$1]; }
  ;

struct_instance_member
  : IDENTIFIER '=' property_expr_list
    { $$ = [$1, $3]; }
  ;


arguments
  : arguments ',' expr { $$ = $1.concat([$3]); }
  | expr { $$ = [$1] }
  ;

label
  : IDENTIFIER ':'
    { $$ = { type: NodeType.Label, path: yy.path, name: $1 } as ASTLabelNode; }
  ;

index_size
  : '.w' { $$ = OperandSize.Word }
  | '.l' { $$ = OperandSize.Long }
  | '.b' { $$ = OperandSize.Byte }
  | '.$' { $$ = OperandSize.MacroArg }
  ;


indirect
  : '(' register ')' { $$ = { type: NodeType.Indirect, path: yy.path, value: $2 } as ASTIndirectNode; }
  | '(' math ')' index_size { $$ = { type: NodeType.Absolute, size: $4, path: yy.path, value: $2 } as ASTAbsoluteNode; }
  | '-' '(' register ')' { $$ = { type: NodeType.Indirect, path: yy.path, value: $3, predecrement: true } as ASTIndirectNode; }
  | '(' register ')' '+' { $$ = { type: NodeType.Indirect, path: yy.path, value: $2, postincrement: true } as ASTIndirectNode; }
  | '(' math ',' register ')' { $$ = { type: NodeType.Indirect, path: yy.path, value: $4, displacement: $2 } as ASTIndirectNode; }
  | '(' math ',' register ',' register index_size ')' { $$ = { type: NodeType.Indirect, path: yy.path, value: $4, displacement: $2, index: $6, indexSize: $7 } as ASTIndirectNode; }
  | '(' register ',' register index_size ')' { $$ = { type: NodeType.Indirect, path: yy.path, value: $2, displacement: { type: NodeType.Number, path: yy.path, value: 0 } as ASTNumberNode, index: $4, indexSize: $5 } as ASTIndirectNode; }
  ;

number
  : NUMBER
    { $$ = { type: NodeType.Number, path: yy.path, value: parseNumber($1) }; }
  ;

expr
  : math
  | string
  | immediate
  | indirect
  | register_list
    { if ($1.registers.length === 1 && $1.registers[0].type === NodeType.Identifier) { $$ = $1.registers[0]; } else { $$ = $1; } }
  ;

property_expr
  : math
  | string
  ;

property_expr_list
  : property_expr_list ',' property_expr { $$ = $1.concat([$3]); }
  | property_expr { $$ = [$1] }
  ;

identifier
  : IDENTIFIER
    { $$ = { type: NodeType.Identifier, path: yy.path, identifier: $1, isRegister: false } as ASTIdentifierNode; }
  ;

immediate
  : '#' math
    { $$ = { type: NodeType.Immediate, path: yy.path, value: $2 } as ASTImmediateNode; }
  | '#' string
    { $$ = { type: NodeType.Immediate, path: yy.path, value: $2 } as ASTImmediateNode; }
  ;

math
  : bitwise
  ;

bitwise
  : bitwise '<<' complex
    { $$ = { type: NodeType.LeftShift, path: yy.path, left: $1, right: $3 } as ASTLeftShiftNode; }
  | bitwise '>>' complex
    { $$ = { type: NodeType.RightShift, path: yy.path, left: $1, right: $3 } as ASTRightShiftNode; }
  | bitwise '|' complex
    { $$ = { type: NodeType.BitwiseOr, path: yy.path, left: $1, right: $3 } as ASTBitwiseOrNode; }
  | bitwise '&' complex
    { $$ = { type: NodeType.BitwiseAnd, path: yy.path, left: $1, right: $3 } as ASTBitwiseAndNode; }
  | '~' complex
    { $$ = { type: NodeType.BitwiseNot, path: yy.path, operand: $2 } as ASTBitwiseNotNode; }
  | complex
  ;

complex
  : complex '+' term
    { $$ = { type: NodeType.Addition, path: yy.path, left: $1, right: $3 } as ASTAdditionNode; }
  | complex '-' term
    { $$ = { type: NodeType.Subtraction, path: yy.path, left: $1, right: $3 } as ASTSubtractionNode; }
  | '-' term %prec UMINUS
    { $$ = { type: NodeType.UnaryMinus, path: yy.path, value: $2 } as ASTUnaryMinusNode; }
  | term
  ;

term
  : term '*' factor
    { $$ = { type: NodeType.Multiplication, path: yy.path, left: $1, right: $3 } as ASTMultiplicationNode; }
  | term '/' factor
    { $$ = { type: NodeType.Division, path: yy.path, left: $1, right: $3 } as ASTDivisionNode; }
  | factor
  ;

factor
  : identifier
  | number
  | '(' math ')'
    { $$ = $2; }
  ;

string
  : STRING
    { $$ = { type: NodeType.String, path: yy.path, value: parseString($1) }; }
  ;

newline
  : newline NEWLINE
  | NEWLINE
  ;
