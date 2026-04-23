module Implode

import Syntax;
import Parser;
import AST;

import ParseTree;
import Node;

public Module implode(Tree pt) = implode(#Module, pt);
public Module load(loc l) = implode(#Module, parseModule(l));