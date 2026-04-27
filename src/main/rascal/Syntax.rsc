module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r];

lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "#" ![\n]* $;

start syntax Module
  = \module: "defmodule" Id modName Import? imp Elements* elems "end"
  ;

// import termina con fin de linea (\n) que es parte del layout.
syntax Import
  = importDecl: "using" Id importedMod
  ;

syntax Elements
  = spaceDef:      SpaceDef
  | operatorDef:   OperatorDef
  | varDef:        VarDef
  | ruleDef:       RuleDef
  | expressionDef: ExpressionDef
  | relationDef:   RelationDef
  | equationDef:   EquationDef
  ;

syntax EquationDef  = equationDef:  "defequation"  Id eqName "end" ;
syntax RelationDef = relationDef: "defrelation" Id relName "end";

syntax SpaceDef
  = withParent: "defspace" Id spaceName "\<" Id parentName "end"
  | withoutParent: "defspace" Id spaceName "end"
  ;

syntax OperatorDef
  = operatorDef: "defoperator" Id opName ":" Domain opDomain "end"
  ;

syntax Domain
  = domain: Id domSrc Arrow+ domArrows
  ;

syntax Arrow
  = arrow: "-\>" Id arrowTarget
  ;

syntax VarDef
  = varDef: "defvar" {Var ","}+ varList "end"
  ;

syntax Var
  = \var: Id varName ":" Id varType
  ;

// lhs: identifier + uno o mas parametros, rhs: identifier + cero o mas parametros
syntax RuleDef
  = ruleDef:
      "defrule" "(" Id lhsName Parameter+ lhsParams ")" "-\>" "(" Id rhsName Parameter* rhsParams ")" "end"
  ;

// parameter ::= identifier | "(" identifier parameter+ ")"
syntax Parameter
  = paramSimple: Id paramId
  | paramNested: "(" Id paramName Parameter+ paramInner ")"
  ;

syntax ExpressionDef
  = expressionDef: "defexpression" Expr exprBody AttributeList? exprAttrs "end"
  ;

// attribute-list ::= "[" attribute (" " attribute)* "]". El separador es espacio, que ya maneja el layout
syntax AttributeList
  = attributeList: "[" Attr+ attrItems "]"
  ;

syntax Attr
  = attrWithValue: Id attrName ":" AttrVal attrVal
  | attrSimple: Id attrName
  ;

// value ::= identifier | number
syntax AttrVal
  = attrValId: Id | attrValNum: Num
  ;

// expression ::= quantifier | logical
syntax Expr
  = quantExpr: Quant | logicalExpr: Logical
  ;

// quantifier ::= ("forall"|"exists") identifier ("in" expression)? "." expression
syntax Quant
  = forallIn: "forall" Id qVar "in" Expr qRange "." Expr qBody
  | forallNoRange: "forall" Id qVar "." Expr qBody
  | existsIn: "exists" Id qVar "in" Expr qRange "." Expr qBody
  | existsNoRange: "exists" Id qVar "." Expr qBody
  ;

// logical ::= relational-exp (logical-op relational-exp)*
syntax Logical
  = logBase: RelExp
  | logChain: Logical LogOp RelExp
  ;

// logical-op ::= "and" | "or" | "=>" | "≡"
syntax LogOp
  = andOp: "and"
  | orOp: "or"
  | impliesOp: "=\>"
  | equivOp: "≡"
  ;

// relational-exp ::= operacion (relational-op operacion)*
syntax RelExp
  = relBase: Operacion
  | relChain: RelExp RelOp Operacion
  ;

syntax RelOp
  = leOp: "\<="
  | geOp: "\>="
  | neOp: "\<\>"
  | ltOp: "\<"
  | gtOp: "\>"
  | eqOp: "="
  | inOp: "in"
  ;

// sum-exp (+/-) < mul-exp (* ** / %) < unary (neg -) < primary
syntax Operacion
  = left  addOp: Operacion "+"  Operacion
  | left  subOp: Operacion "-"  Operacion
  > left  powOp: Operacion "**" Operacion
  | left  mulOp: Operacion "*"  Operacion
  | left  divOp: Operacion "/"  Operacion
  | left  modOp: Operacion "%"  Operacion
  > right negOp: "neg" Operacion
  | right uminusOp: "-"   Operacion
  > numLit: Num
  | parenExpr: "(" Expr ")"
  | idExpr: Id
  ;

// identifier ::= letter (letter | digit | "-")*
lexical Id
  = ([a-z][a-z0-9\-]* !>> [a-z0-9\-]) \ Keywords
  ;

// number ::= digit (digit)* | digit+ "." digit+
lexical Num
  = [0-9]+ "." [0-9]+ !>> [0-9]
  | [0-9]+ !>> [0-9] !>> [.]
  ;

keyword Keywords
  = "defmodule"     | "using"
  | "defspace"      | "defoperator"
  | "defvar"        | "defrule"
  | "defexpression" | "defrelation"
  | "end"
  | "forall"        | "exists"
  | "and"           | "or"
  | "in"            | "neg"
  | "defer"
  ;
