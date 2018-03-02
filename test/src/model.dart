// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library model;

import 'package:persistent/persistent.dart';
import 'package:pretty/pretty.dart' as implem;

_minimumBy(Iterable xs, int compare(x, y)) {
  var result = xs.first;
  for (final x in xs.skip(1)) {
    if (compare(x, result) < 0) {
      result = x;
    }
  }
  return result;
}

/// [str1] is smaller than [str2] iff it is better.
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

class Document implements implem.Document {
  PersistentSet<_SimpleDocument> sdocs;

  Document(PersistentSet<_SimpleDocument> this.sdocs);

  Document operator +(implem.Document doc) {
    final newSdocs = sdocs.expand((sdoc1) =>
    (doc as Document).sdocs.map((sdoc2) => new _Concat(sdoc1, sdoc2)));
    return new Document(new PersistentSet.from(newSdocs));
  }

  Document get group {
    final flattened =
        sdocs.map((d) => d.flatten()) as PersistentSet<_SimpleDocument>;
    return new Document(flattened.union(sdocs));
  }

  Document nest(int n) => new Document(sdocs.map((d) => d.nest(n)));

  String render(int width) {
    compare(s1, s2) => _compareDocs(width, s1, s2);
    return _minimumBy(sdocs.map((d) => d.render()), compare);
  }

  void renderToSink(int width, StringSink sink) {
    sink.write(render(width));
  }

  Document join(Iterable<implem.Document> docs) {
    if (docs.isEmpty) return empty;
    Document result = empty;
    for (Document doc in docs.take(docs.length - 1)) {
      result += doc + this;
    }
    result += docs.last;
    return result;
  }
}

abstract class _SimpleDocument {
  _SimpleDocument flatten();
  _SimpleDocument nest(int n);
  String render();
}

class _Nil extends _SimpleDocument {
  _SimpleDocument flatten() => this;
  _SimpleDocument nest(int n) => this;
  String render() => '';

  int get hashCode => 42;
  bool operator ==(other) => other is _Nil;
}

class _Text extends _SimpleDocument {
  final String str;

  _Text(this.str);

  _SimpleDocument flatten() => this;
  _SimpleDocument nest(int n) => this;
  String render() => str;

  int get hashCode => str.hashCode;
  bool operator ==(other) => (other is _Text) && (str == other.str);
}

class _Concat extends _SimpleDocument {
  final _SimpleDocument left;
  final _SimpleDocument right;

  _Concat(this.left, this.right);

  _SimpleDocument flatten() => new _Concat(left.flatten(), right.flatten());
  _SimpleDocument nest(int n) => new _Concat(left.nest(n), right.nest(n));
  String render() => left.render() + right.render();

  int get hashCode => 31 * left.hashCode + right.hashCode;
  bool operator ==(other) {
    return (other is _Concat)
        && (left == other.left)
        && (right == other.right);
  }
}

class _Line extends _SimpleDocument {
  final int level;
  final _SimpleDocument doc;

  _Line(this.level, this.doc);

  _SimpleDocument flatten() => new _Concat(new _Text(" "), doc);
  _SimpleDocument nest(int n) => new _Line(level + n, doc);
  String render() => '\n' + _spaces() + doc.render();

  String _spaces() => new List.filled(level, ' ').join();

  int get hashCode => 31 * level.hashCode + doc.hashCode;
  bool operator ==(other) {
    return (other is _Line)
        && (level == other.level)
        && (doc == other.doc);
  }
}

_singleton(sdoc) => new Document(new PersistentSet().insert(sdoc));

final Document empty = _singleton(new _Nil());
final Document line = _singleton(new _Line(0, new _Nil()));
Document text(String str) => _singleton(new _Text(str));
