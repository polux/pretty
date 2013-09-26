// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

import 'package:pretty/pretty.dart';

class Tree {
  final String name;
  final List<Tree> children;

  Tree(this.name, this.children);

  Document get pretty => (text(name) + _brackets).group;

  Document get _brackets {
    return children.isEmpty
        ? empty
        : text(" {") + (line + _prettyChildren).nest(2) + line + text("}");
  }

  Document get _prettyChildren {
    return (text(",") + line).join(children.map((c) => c.pretty));
  }
}

final someTree = new Tree("aaa",
    [new Tree("bbbbb",
        [new Tree("ccc", []),
         new Tree("dd", [])]),
    new Tree("eee", []),
    new Tree("ffff",
        [new Tree("gg", []),
         new Tree("hhh", []),
         new Tree("ii", [])])]);

void main() {
  for (int width in [100, 50, 30, 10]) {
    print(someTree.pretty.render(width));
    print("");
  }
}