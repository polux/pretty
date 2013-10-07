// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)
//         Rafael de Andrade (rafa.bra@gmail.com)

import 'factories.dart';
import 'package:pretty/pretty.dart' as impl;

impl.Document join(DocumentFactory factory, { Iterable<dynamic> iterable: const <dynamic>[] }) =>
  iterable.isEmpty
    ? factory.empty
    : (factory.text(',') + factory.line).join(iterable.map(
        (p) => (p is impl.Document) ? p : ( (p is Pretty) ? p.pretty(factory) : factory.text(p.toString()) )
    ));


impl.Document format(DocumentFactory factory, { String name : '', Iterable<dynamic> iterable: const <dynamic>[],
                int identation: 2, String delimiters: '{}', impl.Document emptyValue }) {

  name = name.trim();

  if (name.isEmpty && iterable.isEmpty) {
    return factory.empty;
  }
  else if (!name.isEmpty && iterable.isEmpty) {
    return factory.text(name) + ((emptyValue == null) ? factory.empty : factory.space + emptyValue);
  }
  return
    (name.isEmpty ? factory.empty : factory.text(name) + factory.space) +
    factory.text(delimiters[0]) +
      (factory.line + join(factory, iterable: iterable)).nest(identation) +
      factory.line + factory.text(delimiters[1]);
}


impl.Document object(DocumentFactory factory, { String name : '', Iterable<dynamic> iterable: const <dynamic>[], int identation: 2 }) =>
  format(factory, name: name, iterable: iterable, identation: identation, delimiters: '{}');


impl.Document list(DocumentFactory factory, { String name : '', Iterable<dynamic> iterable: const <dynamic>[], int identation: 2 }) =>
  format(factory, name: name, iterable: iterable, identation: identation, delimiters: '[]', emptyValue: factory.text('[]'));


abstract class Pretty {
  impl.Document pretty(DocumentFactory factory);
}

class PrettyTree extends Object with Pretty {
  final String name;
  final List<PrettyTree> children;

  PrettyTree(this.name, this.children);

  impl.Document pretty(DocumentFactory factory) => object(factory, name: name, iterable: children).group;
}