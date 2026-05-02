module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;
import Syntax;
import Checker;
import Generator;

PathConfig pcfg = getProjectPathConfig(|project://verilangl|, mode=interpreter());

Language verilangLang = language(pcfg, "VeriLang", "vl", "Plugin", "contribs");

// Comando para el lense
data Command = gen(Module p);

// Summarizer
Summary verilangSummarizerPlugin(loc l, start[Module] input) {
    tm = verilangTModelFromTree(input);
    defs = getUseDef(tm);
    return summary(l,
        messages    = {<m.at, m> | m <- getMessages(tm), !(m is info)},
        definitions = defs
    );
}

set[LanguageService] contribs() = {
   
    parser(start[Module] (str program, loc src) {
        return parse(#start[Module], program, src);
    }),
    // Lenses: boton "Generate output" encima del .vl abierto
    // igual que el tutorial registra "Generate text file"
    lenses(rel[loc src, Command lens] (start[Module] p) {
        return {
            <p.src, gen(p.top, title="Generate output")>
        };
    }),
    // Summarizer: muestra errores de tipos en el IDE
    summarizer(verilangSummarizerPlugin),
    // Executor: ejecuta el comando gen
    executor(exec)
};

// exec: igual que value exec(gen1(Planning p)) en el tutorial
value exec(gen(Module p)) {
    cast = parse(#start[Module],
        |project://verilangl/src/main/rascal/instance/test.vl|);
    rVal = generator(cast);
    outputFile = |project://verilangl/src/main/rascal/instance/output.txt|;
    writeFile(outputFile, rVal);
    edit(outputFile);
    return ("result": true);
}

void main() {
    registerLanguage(verilangLang);
}
