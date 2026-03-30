module Syntax

layout Whitespace = [\ \t\n\r]*;

lexical Identifier = [a-z] [a-z0-9\-]*;
lexical Number = [0-9]+ ("." [0-9]+)?;

start syntax Module
    = 'defmodule' Identifier Import? Elements* 'end'
    ;

syntax Import
    = 'using' Identifier '\n'
    ;

syntax Elements
    = Spacedef
    | Operatordef
    | Vardef
    | Ruledef
    | Expressiondef
    ;

syntax Spacedef
    = 'defspace' Identifier ('<' Identifier)? 'end'
    ;

syntax Operatordef
    = 'defoperator' Identifier ':' Domain 'end'
    ;

syntax Domain
    = Identifier ('->' Identifier)+
    ;

syntax Vardef
    = 'defvar' Variable (',' Variable)* 'end'
    ;

syntax Variable
    = Identifier ':' Identifier
    ;

syntax Ruledef
    = 'defrule' '(' Identifier Parameter Parameter ')' '->' '(' Identifier Parameter ')' 'end'
    ;

syntax Parameter
    = Identifier
    | '(' Identifier Parameter ')'
    ;

syntax Expressiondef
    = 'defexpression' Expression AttributeList? 'end'
    ;

syntax AttributeList
    = '[' Attribute+ ']'
    ;

syntax Attribute
    = Identifier (':' Value)?
    ;

syntax Value
    = Identifier
    | Number
    ;

syntax Expression
    = Quantifier
    | Logical
    ;

syntax Quantifier
    = ('forall' | 'exists') Identifier ('in' Expression)? '.' Expression
    ;

syntax Logical
    = RelationalExp (LogicalOp RelationalExp)*
    ;

syntax LogicalOp
    = 'and' | 'or' | '=>' | '≡'
    ;

syntax RelationalExp
    = Operacion (RelationalOp Operacion)*
    ;

syntax RelationalOp
    = '<' | '>' | '<=' | '>=' | '=' | '<>' | 'in'
    ;

syntax Operacion
    = SumExp
    | MulExp
    | Unary
    | Primary
    ;

syntax SumExp
    = MulExp
    | SumExp ('+' | '-') MulExp
    ;

syntax MulExp
    = Unary
    | MulExp ('*' | '**' | '/' | '%') Unary
    ;

syntax Unary
    = Primary
    | ('neg' | '-')? Unary
    ;

syntax Primary
    = Number
    | '(' Expression ')'
    | Identifier
    ;

keyword Reserved = "defmodule" | "using" | "defspace" | "defoperator" | "defvar" | "defrule" | "defexpression" | "defrelation" | "end" | "in" | "forall" 
    | "exists" | "and" | "or" | 'neg';