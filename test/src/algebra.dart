// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library algebra;

import 'factories.dart';
import 'package:enumerators/enumerators.dart' as en;
import 'package:enumerators/combinators.dart' as en;

abstract class Document {
  convert(DocumentFactory factory);
}

class _Empty extends Document {
  _Empty();

  toString() => "Empty";
  convert(DocumentFactory factory) => factory.empty;
}

class _Line extends Document {
  _Line();

  toString() => "Line";
  convert(DocumentFactory factory) => factory.line;
}

class _Text extends Document {
  final String str;
  _Text(this.str);

  toString() => "Text($str)";
  convert(DocumentFactory factory) => factory.text(str);
}

class _Plus extends Document {
  final Document doc1;
  final Document doc2;
  _Plus(this.doc1, this.doc2);

  toString() => "Plus($doc1, $doc2)";
  convert(DocumentFactory factory) {
    return doc1.convert(factory) + doc2.convert(factory);
  }
}

class _Group extends Document {
  final Document doc;
  _Group(this.doc);

  toString() => "Group($doc)";
  convert(DocumentFactory factory) => doc.convert(factory).group;
}

class _Nest extends Document {
  final Document doc;
  final int level;
  _Nest(this.doc, this.level);

  toString() => "Nest($doc, $level)";
  convert(DocumentFactory factory) => doc.convert(factory).nest(level);
}

final _strs = ["", "a", "cd", "efg"].map(en.singleton).reduce((x, y) => x + y);
final _empties = en.singleton(new _Empty());
final _lines = en.singleton(new _Line());
final _texts = en.singleton((str) => new _Text(str)).apply(_strs);
_plusses(docs1, docs2) {
  return en.singleton((doc1) => (doc2) => new _Plus(doc1, doc2))
           .apply(docs1)
           .apply(docs2);
}
_groups(docs) => en.singleton((doc) => new _Group(doc)).apply(docs);
_nests(docs) {
  return en.singleton((doc) => (level) => new _Nest(doc, level))
           .apply(docs)
           .apply(en.nats);
}

en.Enumeration<Document> get documents {
  return en.fix((e) =>
      _empties +
      _lines +
      _texts +
      _plusses(e, e).pay() +
      _groups(e).pay() +
      _nests(e).pay());
}