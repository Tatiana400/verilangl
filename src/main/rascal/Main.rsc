module Main

import IO;
import Parser;
import Generator;

void main() {
    tree = parseModule(|project://verilangl/src/main/rascal/instance/test.vl|);
    rVal = generator(tree);
    println(rVal);
    writeFile(|project://verilangl/src/main/rascal/instance/output.txt|, rVal);
}