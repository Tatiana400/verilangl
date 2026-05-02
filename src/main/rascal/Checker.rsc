module Checker

import Syntax;
import ParseTree;
import String;
import analysis::typepal::TypePal;
extend analysis::typepal::TypePal;

// ── ADTs para TypePal (igual que el tutorial define personId y personType) ────

data IdRole
  = spaceId()
  | operatorId()
  | varId()
  ;

data AType
  = spaceType()
  | operatorType()
  | varType(str typeName)
  ;

// DefInfo extendido para guardar info de espacios (igual que el tutorial, extiende DefInfo con list[Person] person = [])
data DefInfo(str spaceName = "", str parentName = "");

// ── TModel (igual que modulesTModelFromTree en el tutorial) ──────────────────

public TModel verilangTModelFromTree(Tree pt) {
    if (pt has top) pt = pt.top;
    TypePalConfig cfg = getVeriLangConfig();
    c = newCollector("collectAndSolve", pt, cfg);
    collect(pt, c);
    return newSolver(pt, c.run()).run();
}

private TypePalConfig getVeriLangConfig() = tconfig(
    verbose             = true,
    logTModel           = true,
    logAttempts         = true,
    logSolverIterations = true,
    logSolverSteps      = true
);

// ── collect: recolecta definiciones y usos
// defspace name end  -> define un espacio sin padre
void collect(current: (SpaceDef) `defspace <Id name> end`, Collector c) {
    dt = defType(spaceType());
    dt.spaceName = "<name>";
    c.define("<name>", spaceId(), name, dt);
}

// defspace name < parent end  -> define espacio y usa el padre
void collect(current: (SpaceDef) `defspace <Id name> \< <Id parent> end`, Collector c) {
    dt = defType(spaceType());
    dt.spaceName  = "<name>";
    dt.parentName = "<parent>";
    c.define("<name>", spaceId(), name, dt);
    c.use(parent, {spaceId()});
}

// defoperator name : domain end  -> define operador, usa los espacios del dominio
void collect(current: (OperatorDef) `defoperator <Id name> : <Domain dom> end`, Collector c) {
    c.define("<name>", operatorId(), name, defType(operatorType()));
    c.use(dom.domSrc, {spaceId()});
    for (Arrow arr <- dom.domArrows) {
        c.use(arr.arrowTarget, {spaceId()});
    }
}

// defvar x : T , y : T end  -> define variables, verifica que el tipo sea un espacio
void collect(current: (VarDef) `defvar <{Var ","}+ vars> end`, Collector c) {
    for (v <- vars) {
        c.define("<v.varName>", varId(), v.varName,
                 defType(varType("<v.varType>")));
        c.use(v.varType, {spaceId()});
    }
}

// Identificadores en expresiones -> uso de variable u operador
void collect(current: (Operacion) `<Id id>`, Collector c) {
    c.use(id, {varId(), operatorId()});
}

// ── Summarizer para el IDE, igual que tdslSummarizer en el tutorial
Summary verilangSummarizer(loc l, start[Module] input) {
    tm = verilangTModelFromTree(input);
    defs = getUseDef(tm);
    return summary(l,
        messages    = {<m.at, m> | m <- getMessages(tm), !(m is info)},
        definitions = defs
    );
}
