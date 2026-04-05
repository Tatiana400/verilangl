module AST

data Module
  = \module(str modName, list[Import] imp, list[Elements] elems)
  ;

data Import
  = importDecl(str importedMod)
  ;

data Elements
  = spaceDef(SpaceDef sd)
  | operatorDef(OperatorDef od)
  | varDef(VarDef vd)
  | ruleDef(RuleDef rd)
  | expressionDef(ExpressionDef ed)
  ;

data SpaceDef
  = withParent(str spaceName, str parentName)
  | withoutParent(str spaceName)
  ;

data OperatorDef
  = operatorDef(str opName, Domain opDomain)
  ;

data Domain
  = domain(str domSrc, list[str] domTargets)
  ;

data VarDef
  = varDef(list[Var] varList)
  ;

data Var
  = \var(str varName, str varType)
  ;

data RuleDef
  = ruleDef(str lhsName, list[Parameter] lhsParams,
            str rhsName, list[Parameter] rhsParams)
  ;

data Parameter
  = paramSimple(str paramId)
  | paramNested(str paramName, list[Parameter] paramInner)
  ;

data ExpressionDef
  = expressionDef(Expr exprBody, list[AttributeList] exprAttrs)
  ;

data AttributeList
  = attributeList(list[Attr] attrItems)
  ;

data Attr
  = attrWithValue(str attrName, AttrVal attrVal)
  | attrSimple(str attrName)
  ;

data AttrVal
  = attrValId(str attrId)
  | attrValNum(str attrNum)
  ;

data Expr
  = quantExpr(Quant qExpr)
  | logicalExpr(Logical logExpr)
  ;

data Quant
  = forallIn(str qVar, Expr qRange, Expr qBody)
  | forallNoRange(str qVar, Expr qBody)
  | existsIn(str qVar, Expr qRange, Expr qBody)
  | existsNoRange(str qVar, Expr qBody)
  ;

data Logical
  = logBase(RelExp relExpr)
  | logChain(Logical logLeft, LogOp logOp, RelExp relExpr)
  ;

data LogOp
  = andOp()
  | orOp()
  | impliesOp()
  | equivOp()
  ;

data RelExp
  = relBase(Oper operand)
  | relChain(RelExp relLeft, RelOp relOp, Oper operand)
  ;

data RelOp
  = ltOp()
  | gtOp()
  | leOp()
  | geOp()
  | eqOp()
  | neOp()
  | inOp()
  ;

data Oper
  = addOp(Oper lhs, Oper rhs)
  | subOp(Oper lhs, Oper rhs)
  | mulOp(Oper lhs, Oper rhs)
  | divOp(Oper lhs, Oper rhs)
  | modOp(Oper lhs, Oper rhs)
  | powOp(Oper lhs, Oper rhs)
  | negOp(Oper unaryArg)
  | uminusOp(Oper unaryArg)
  | numLit(str numVal)
  | parenExpr(Expr innerExpr)
  | idExpr(str idVal)
  ;
