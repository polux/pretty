// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)
//         Rafael Brandão (rafa.bra@gmail.com)

import 'package:pretty/pretty_extras.dart';

class Tree extends Object with Pretty {
  final String name;
  final List<Tree> children;

  Tree(this.name, this.children);

  Document get pretty =>
    prettyTree(name, children.map((Tree t) => t.pretty));

  // This is optional, defaults to 2;
  //int get indentation => 2;
}

final Tree someTree = new Tree("aaa",
    [new Tree("bbbbb",
        [new Tree("ccc", []),
         new Tree("dd", [])]),
    new Tree("eee", []),
    new Tree("ffff",
        [new Tree("gg", []),
         new Tree("hhh", []),
         new Tree("ii", [])])]);

void main() {
  for (int width in [100, 50, 20, 10]) {
    print(someTree.render(width));
    print("");
  }
}
