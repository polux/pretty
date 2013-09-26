// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library test_helpers;

import 'package:pretty/pretty.dart' as implem;
import 'model.dart' as model;

abstract class DocumentFactory {
  implem.Document empty;
  implem.Document line;
  implem.Document text(String str);
}

class ImplemFactory extends DocumentFactory {
  implem.Document empty = implem.empty;
  implem.Document line = implem.line;
  implem.Document text(String str) => implem.text(str);
}

class ModelFactory extends DocumentFactory {
  implem.Document empty = model.empty;
  implem.Document line = model.line;
  implem.Document text(String str) => model.text(str);
}

final implemFactory = new ImplemFactory();
final modelFactory = new ModelFactory();

class Tree {
  final String name;
  final List<Tree> children;

  Tree(this.name, this.children);

  implem.Document pretty(DocumentFactory factory) {
    return (factory.text(name) + _brackets(factory)).group;
  }

  implem.Document _brackets(DocumentFactory factory) {
    return children.isEmpty
        ? factory.empty
        : (factory.text(" {") +
              (factory.line + _prettyChildren(factory)).nest(2) +
              factory.line + factory.text("}"));
  }

  implem.Document _prettyChildren(DocumentFactory factory) {
    return (factory.text(",") + factory.line)
        .join(children.map((c) => c.pretty(factory)));
  }
}
