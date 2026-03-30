module AST

data Module = module(str name, list[Element] elements);

data Element
    = spacedef(str name, str? parent)
    | operatordef(str name, list[str] domain)
    | vardef(list[Variable] vars)
    | ruledef(str op, str p1, str p2)
    | expressiondef(Expression expr)
    ;

data Variable = variable(str name, str type);

data Expression
    = quantifier(str kind, str var, Expression expr)
    | logical(list[Expression] exprs)
    | relation(Expression left, str op, Expression right)
    | binary(Expression left, str op, Expression right)
    | unary(str op, Expression expr)
    | primary(str value)
    ;

