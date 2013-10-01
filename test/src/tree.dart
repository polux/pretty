// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library test_helpers;

import 'factories.dart';
import 'package:pretty/pretty.dart';

class Tree {
  final String name;
  final List<Tree> children;

  Tree(this.name, this.children);

  Document pretty(DocumentFactory factory) {
    return (factory.text(name) + _brackets(factory)).group;
  }

  Document _brackets(DocumentFactory factory) {
    return children.isEmpty
        ? factory.empty
        : (factory.text(" {") +
              (factory.line + _prettyChildren(factory)).nest(2) +
              factory.line + factory.text("}"));
  }

  Document _prettyChildren(DocumentFactory factory) {
    return (factory.text(",") + factory.line)
        .join(children.map((c) => c.pretty(factory)));
  }
}

