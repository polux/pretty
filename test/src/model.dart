// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library model;

import 'package:persistent/persistent.dart';
import 'package:pretty/pretty.dart' as implem;

class Document implements implem.Document {
  final PersistentSet<String> strs;

  Document(this.strs);
  Document._from(Iterable<String> strs) : this(new PersistentSet.from(strs));

  Document operator +(Document doc) {
    return new Document._from(strs.expand(
        (str1) => doc.strs.map((str2) => str1 + str2)));
  }

  static final _SPACES = new RegExp(r"\s+", multiLine: true);
  String _flatten(String str) => str.replaceAll(_SPACES, ' ');
  Document get group => new Document(strs.insert(_flatten(strs.first)));

  _spaces(int n) => new List.filled(n, ' ').join('');
  Document nest(int n) {
    return new Document._from(strs.map(
        (str) => str.replaceAll('\n', '\n' + _spaces(n))));
  }

  int _compareDocs(int width, String str1, String str2) {
    return _lexico(width, str1.split('\n'), str2.split('\n'));
  }
  int _lexico(int width, Iterable lines1, Iterable lines2) {
    if (lines1.isEmpty && lines2.isEmpty) return 0;
    if (lines1.isEmpty) return -1;
    if (lines2.isEmpty) return 1;
    final comp = _compareLines(width, lines1.first, lines2.first);
    return (comp == 0)
        ? _lexico(width, lines1.skip(1), lines2.skip(1))
        : comp;
  }
  int _compareLines(int width, String line1, String line2) {
    if (line1.length <= width && line2.length <= width)
      return line2.length.compareTo(line1.length);
    if (line1.length <= width && line2.length > width)
      return -1;
    if (line1.length > width && line2.length <= width)
      return 1;
    return line1.length.compareTo(line2.length);
  }
  String render(int width) {
    return (strs.toList()..sort((s1, s2) => _compareDocs(width, s1, s2))).first;
  }

  void renderToSink(int width, StringSink sink) {
    sink.write(render(width));
  }

  Document join(Iterable<Document> docs) {
    if (docs.isEmpty) return empty;
    Document result = empty;
    for (Document doc in docs.take(docs.length - 1)) {
      result += doc + this;
    }
    result += docs.last;
    return result;
  }
}

_singleton(str) => new Document(new PersistentSet.from([str]));

final Document empty = _singleton("");
final Document line = _singleton("\n");
Document text(String str) => _singleton(str);