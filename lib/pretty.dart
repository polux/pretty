// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library pretty;

abstract class _Stack {
  bool get isEmpty;
  _Stack cons(int level, bool flat, Document doc) {
    return new _NonEmptyStack(level, flat, doc, this);
  }
}

class _NonEmptyStack extends _Stack {
  final int level;
  final bool flat;
  final Document doc;
  final _Stack tail;
  final bool isEmpty = false;

  _NonEmptyStack(this.level, this.flat, this.doc, this.tail);
}

class _EmptyStack extends _Stack {
  final bool isEmpty = true;
  _EmptyStack();
}

class _DocType {
  final int number;
  const _DocType(this.number);

  static const _DocType NIL = const _DocType(0);
  static const _DocType CONCAT = const _DocType(1);
  static const _DocType NEST = const _DocType(2);
  static const _DocType TEXT = const _DocType(3);
  static const _DocType LINE = const _DocType(4);
  static const _DocType GROUP = const _DocType(5);
}

abstract class Document {
  _DocType get _type;

  static bool debug = true;
  static bool _fits(int width, _Stack stack) {
    while (true) {
      if (width < 0) return false;
      if (stack.isEmpty) return true;
      else {
        _NonEmptyStack nStack = stack;
        int level = nStack.level;
        bool flat = nStack.flat;
        Document doc = nStack.doc;
        _Stack tail = nStack.tail;

        switch (doc._type) {
          case _DocType.NIL:
            stack = tail;
            break;
          case _DocType.CONCAT:
            _Concat concat = doc;
            stack = tail
                .cons(level, flat, concat.right)
                .cons(level, flat, concat.left);
            break;
          case _DocType.TEXT:
            _Text text = doc;
            width -= text.str.length;
            stack = tail;
            break;
          case _DocType.NEST:
            _Nest nest = doc;
            stack = tail.cons(level + nest.n, flat, nest.doc);
            break;
          case _DocType.LINE:
            if (flat) {
              width--;
              stack = tail;
            } else {
              return true;
            }
            break;
          case _DocType.GROUP:
            _Group group = doc;
            stack = tail.cons(level, flat, group.doc);
            break;
        }
      }
    }
  }

  Document operator +(Document doc) => new _Concat(this, doc);
  Document nest(int n) => new _Nest(n, this);
  Document get group => new _Group(this);
  Document join(Iterable<Document> docs) {
    if (docs.isEmpty) return empty;
    Document result = empty;
    for (Document doc in docs.take(docs.length - 1)) {
      result += doc + this;
    }
    result += docs.last;
    return result;
  }

  void renderToSink(int width, StringSink sink) {
    int numChars = 0;
    _Stack stack = new _EmptyStack().cons(0, false, this);
    while (!stack.isEmpty) {
      _NonEmptyStack nStack = stack;
      int level = nStack.level;
      bool flat = nStack.flat;
      Document doc = nStack.doc;
      _Stack tail = nStack.tail;

      switch (doc._type) {
        case _DocType.NIL:
          stack = tail;
          break;
        case _DocType.CONCAT:
          _Concat concat = doc;
          stack = tail
              .cons(level, flat, concat.right)
              .cons(level, flat, concat.left);
          break;
        case _DocType.TEXT:
          _Text text = doc;
          String str = text.str;
          sink.write(str);
          numChars += str.length;
          stack = tail;
          break;
        case _DocType.NEST:
          _Nest nest = doc;
          stack = tail.cons(level + nest.n, flat, nest.doc);
          break;
        case _DocType.LINE:
          if (flat) {
            sink.write(" ");
            numChars++;
            stack = tail;
          } else {
            sink.write("\n");
            for (int i = 0; i < level; i++) {
              sink.write(" ");
            }
            numChars = level;
            stack = tail;
          }
          break;
        case _DocType.GROUP:
          _Group group = doc;
          if (_fits(width - numChars, tail.cons(level, true, group.doc))) {
            stack = tail.cons(level, true, group.doc);
          } else {
            stack = tail.cons(level, false, group.doc);
          }
          break;
      }
    }
  }

  String render(int width) {
    StringBuffer buffer = new StringBuffer();
    renderToSink(width, buffer);
    return buffer.toString();
  }
}

class _Nil extends Document {
  final _DocType _type = _DocType.NIL;
  final int hashCode = "Nil".hashCode;

  _Nil();

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Nil);
  }

  String toString() => "Nil()";
}

class _Concat extends Document {
  final _DocType _type = _DocType.CONCAT;
  final Document left;
  final Document right;
  final int hashCode;

  _Concat(Document left, Document right)
      : this.left = left
      , this.right = right
      , this.hashCode = _Concat._hashCode(left, right);

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Concat  && left == other.left && right == other.right);
  }

  static int _hashCode(left, right) {
    int result = "Concat".hashCode;
    result = 31 * result + left.hashCode;
    result = 31 * result + right.hashCode;
    return result;
  }

  String toString() => "Concat($left, $right)";

  _Concat copy({Document left, Document right}) {
    return new _Concat(
        (left != null) ? left : this.left,
        (right != null) ? right : this.right);
  }
}

class _Nest extends Document {
  final _DocType _type = _DocType.NEST;
  final int n;
  final Document doc;
  final int hashCode;

  _Nest(int n, Document doc)
      : this.n = n
      , this.doc = doc
      , this.hashCode = _Nest._hashCode(n, doc);

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Nest && n == other.n && doc == other.doc);
  }

  static int _hashCode(n, doc) {
    int result = "Nest".hashCode;
    result = 31 * result + n.hashCode;
    result = 31 * result + doc.hashCode;
    return result;
  }

  String toString() => "Nest($n, $doc)";

  _Nest copy({int n, Document doc}) {
    return new _Nest(
        (n != null) ? n : this.n,
        (doc != null) ? doc : this.doc);
  }
}

class _Text extends Document {
  final _DocType _type = _DocType.TEXT;
  final String str;
  final int hashCode;

  _Text(String str)
      : this.str = str
      , this.hashCode = _Text._hashCode(str);

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Text && str == other.str);
  }

  static int _hashCode(str) {
    int result = "Text".hashCode;
    result = 31 * result + str.hashCode;
    return result;
  }

  String toString() => "Text($str)";

  _Text copy({String str}) {
    return new _Text((str != null) ? str : this.str);
  }
}

class _Line extends Document {
  final _DocType _type = _DocType.LINE;
  final int hashCode = "Line".hashCode;

  _Line();

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Line);
  }

  String toString() => "Line()";
}

class _Group extends Document {
  final _DocType _type = _DocType.GROUP;
  final Document doc;
  final int hashCode;

  _Group(Document doc)
      : this.doc = doc
      , this.hashCode = _Group._hashCode(doc);

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Group && doc == other.doc);
  }

  static int _hashCode(doc) {
    int result = "Group".hashCode;
    result = 31 * result + doc.hashCode;
    return result;
  }

  String toString() => "Group($doc)";

  _Group copy({Document doc}) {
    return new _Group((doc != null) ? doc : this.doc);
  }
}


Document join({ Iterable<dynamic> iterable: const <dynamic>[] }) =>
  iterable.isEmpty
    ? empty
    : (text(',') + line).join(iterable.map(
        (p) => (p is Document) ? p : ( (p is Pretty) ? p.pretty : text(p.toString()) )
    ));


Document format({ String name : '', Iterable<dynamic> iterable: const <dynamic>[], int identation: 2,
                String delimiters: '{}', Document emptyValue }) {

  name = name.trim();

  if (name.isEmpty && iterable.isEmpty) {
    return empty;
  }
  else if (!name.isEmpty && iterable.isEmpty) {
    return text(name) + ((emptyValue == null) ? empty : space + emptyValue);
  }
  return
    (name.isEmpty ? empty : text(name) + space) +
    text(delimiters[0]) + (line + join(iterable: iterable)).nest(identation) + line + text(delimiters[1]);
}


Document object({ String name : '', Iterable<dynamic> iterable: const <dynamic>[], int identation: 2 }) =>
  format(name: name, iterable: iterable, identation: identation, delimiters: '{}');


Document list({ String name : '', Iterable<dynamic> iterable: const <dynamic>[], int identation: 2 }) =>
  format(name: name, iterable: iterable, identation: identation, delimiters: '[]', emptyValue: text('[]'));


abstract class Pretty {
  Document get pretty;

  String toString() => pretty.group.render(0);
}

final Document empty = new _Nil();
Document text(String str) => new _Text(str);
final Document line = new _Line();
final Document space = new _Text(' ');