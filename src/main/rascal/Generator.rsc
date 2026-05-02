module Generator

import IO;
import Set;
import List;
import AST;
import Syntax;
import String;
import Parser;
import Implode;

data GenElement = genElement(str kind = "", str name = "", str detail = "");

list[str]        allImports  = [];
list[GenElement] allElements = [];

void main() {
    tree = parseModule(|project://verilangl/src/main/rascal/instance/test.vl|);
    rVal = generator(tree);
    println(rVal);
    writeFile(|project://verilangl/src/main/rascal/instance/output.txt|, rVal);
}

str generator(tree) {
    ast = implode(tree);
    allImports  = [];
    allElements = [];
    generate(ast);
    str importLines  = intercalate("\n", ["  using <i>" | i <- allImports]);
    str elementLines = intercalate("\n",
        ["  [<e.kind>] <e.name> : <e.detail>" | e <- allElements]);
    str rVal =
        "VeriLang Module: <ast.modName>
        '==============================
        'Imports:
        '<importLines>
        'Elements:
        '------------------------------
        '<elementLines>
        '==============================
        '";
    return rVal;
}

void generate(Module m) {
    for (imp <- m.imp)    generate(imp);
    for (elem <- m.elems) generate(elem);
}

void generate(Import imp) {
    allImports += ["<imp.importedMod>"];
}

void generate(Elements elem) {
    if (elem.sd?)  generate(elem.sd);
    if (elem.od?)  generate(elem.od);
    if (elem.vd?)  generate(elem.vd);
    if (elem.rd?)  generate(elem.rd);
    if (elem.ed?)  generate(elem.ed);
    if (elem.red?) generate(elem.red);
    if (elem.eqd?) generate(elem.eqd);
}

void generate(SpaceDef sd) {
    if (sd.parentName?) {
        allElements += [genElement(kind="Space", name="<sd.spaceName>",
                         detail="subspace of <sd.parentName>")];
    } else {
        allElements += [genElement(kind="Space", name="<sd.spaceName>",
                         detail="root space")];
    }
}

void generate(OperatorDef od) {
    allElements += [genElement(kind="Operator", name="<od.opName>",
                     detail=generateDomain(od.opDomain))];
}

str generateDomain(Domain dom) {
    str result = "<dom.domSrc>";
    for (t <- dom.domTargets) {
        result += " -> <t>";
    }
    return result;
}

void generate(VarDef vd) {
    for (\var(str vname, str vtype) <- vd.varList) {
        allElements += [genElement(kind="Var", name=vname, detail=vtype)];
    }
}

void generate(RuleDef rd) {
    str lhsParams = intercalate(" ", [generateParam(p) | p <- rd.lhsParams]);
    str rhsParams = intercalate(" ", [generateParam(p) | p <- rd.rhsParams]);
    str lhs = "(<rd.lhsName> <lhsParams>)";
    str rhs = "(<rd.rhsName> <rhsParams>)";
    allElements += [genElement(kind="Rule", name="<rd.lhsName>",
                     detail="<lhs> -> <rhs>")];
}

str generateParam(Parameter p) {
    if (paramSimple(str pid) := p) {
        return pid;
    }
    if (paramNested(str pname, list[Parameter] inner) := p) {
        str innerStr = intercalate(" ", [generateParam(q) | q <- inner]);
        return "(<pname> <innerStr>)";
    }
    return "";
}

void generate(ExpressionDef ed) {
    str exprStr = generateExpr(ed.exprBody);
    str attrStr = "";
    for (AttributeList al <- ed.exprAttrs) {
        attrStr = " [<generateAttrList(al)>]";
    }
    allElements += [genElement(kind="Expression", name="expr",
                     detail="<exprStr><attrStr>")];
}

str generateAttrList(AttributeList al) {
    if (attributeList(list[Attr] items) := al) {
        return intercalate(" ", [generateAttr(a) | a <- items]);
    }
    return "";
}

str generateAttr(Attr a) {
    if (attrSimple(str aname) := a) {
        return aname;
    }
    if (attrWithValue(str aname, AttrVal aval) := a) {
        return "<aname>: <generateAttrVal(aval)>";
    }
    return "";
}

str generateAttrVal(AttrVal av) {
    if (attrValId(str aid) := av)   return aid;
    if (attrValNum(str anum) := av) return anum;
    return "";
}

void generate(RelationDef red) {
    allElements += [genElement(kind="Relation", name="<red.relName>", detail="")];
}

void generate(EquationDef eqd) {
    allElements += [genElement(kind="Equation", name="<eqd.eqName>", detail="")];
}

str generateExpr(Expr e) {
    if (quantExpr(Quant q) := e)     return generateQuant(q);
    if (logicalExpr(Logical l) := e) return generateLogical(l);
    return "";
}

str generateQuant(Quant q) {
    if (forallIn(str v, Expr range, Expr body) := q)
        return "forall <v> in <generateExpr(range)> . <generateExpr(body)>";
    if (forallNoRange(str v, Expr body) := q)
        return "forall <v> . <generateExpr(body)>";
    if (existsIn(str v, Expr range, Expr body) := q)
        return "exists <v> in <generateExpr(range)> . <generateExpr(body)>";
    if (existsNoRange(str v, Expr body) := q)
        return "exists <v> . <generateExpr(body)>";
    return "";
}

str generateLogical(Logical l) {
    if (logBase(RelExp r) := l)
        return generateRelExp(r);
    if (logChain(Logical left, LogOp op, RelExp r) := l)
        return "<generateLogical(left)> <generateLogOp(op)> <generateRelExp(r)>";
    return "";
}

str generateLogOp(LogOp op) {
    if (andOp()     := op) return "and";
    if (orOp()      := op) return "or";
    if (impliesOp() := op) return "=>";
    if (equivOp()   := op) return "===";
    return "";
}

str generateRelExp(RelExp r) {
    if (relBase(Oper oper) := r)
        return generateOper(oper);
    if (relChain(RelExp left, RelOp op, Oper oper) := r)
        return "<generateRelExp(left)> <generateRelOp(op)> <generateOper(oper)>";
    return "";
}

str generateRelOp(RelOp op) {
    if (ltOp() := op) return "<";
    if (gtOp() := op) return ">";
    if (leOp() := op) return "<=";
    if (geOp() := op) return ">=";
    if (eqOp() := op) return "=";
    if (neOp() := op) return "<>";
    if (inOp() := op) return "in";
    return "";
}

str generateOper(Oper o) {
    if (addOp(Oper l, Oper r)  := o) return "<generateOper(l)> + <generateOper(r)>";
    if (subOp(Oper l, Oper r)  := o) return "<generateOper(l)> - <generateOper(r)>";
    if (mulOp(Oper l, Oper r)  := o) return "<generateOper(l)> * <generateOper(r)>";
    if (divOp(Oper l, Oper r)  := o) return "<generateOper(l)> / <generateOper(r)>";
    if (modOp(Oper l, Oper r)  := o) return "<generateOper(l)> % <generateOper(r)>";
    if (powOp(Oper l, Oper r)  := o) return "<generateOper(l)> ** <generateOper(r)>";
    if (negOp(Oper u)          := o) return "neg <generateOper(u)>";
    if (uminusOp(Oper u)       := o) return "- <generateOper(u)>";
    if (numLit(str n)          := o) return n;
    if (parenExpr(Expr inner)  := o) return "(<generateExpr(inner)>)";
    if (idExpr(str id)         := o) return id;
    return "";
}