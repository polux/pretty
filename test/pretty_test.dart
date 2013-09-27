// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

import 'package:unittest/unittest.dart';
import 'src/test_helpers.dart';

final someTree = new Tree("aaa",
    [new Tree("bbbbb",
        [new Tree("ccc", []),
         new Tree("dd", [])]),
    new Tree("eee", []),
    new Tree("ffff",
        [new Tree("gg", []),
         new Tree("hhh", []),
         new Tree("ii", [])])]);

void checkImplemMatchesModelForWidth(int width) {
  expect(
      someTree.pretty(implemFactory).render(width),
      equals(someTree.pretty(modelFactory).render(width)));
}

void testImplemMatchesModel() {
  for (int width = 0; width < 100; width++) {
    checkImplemMatchesModelForWidth(width);
  }
}

main() {
  final prettyTree = someTree.pretty(implemFactory);
  print(prettyTree.render(19));
  print(prettyTree.render(18));
  //test('implem matches model', testImplemMatchesModel);
}