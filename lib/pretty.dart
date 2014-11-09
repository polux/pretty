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
  static const _DocType OR = const _DocType(6);
}

abstract class Document {
  const Document._();

  _DocType get _type;

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
            _Line line = doc;
            if (flat) {
              width -= line.alternative.length;
              stack = tail;
            } else {
              return true;
            }
            break;
          case _DocType.GROUP:
            _Group group = doc;
            stack = tail.cons(level, flat, group.doc);
            break;
          case _DocType.OR:
            _Or or = doc;
            stack = tail.cons(level, flat, or.doc1);
            break;
        }
      }
    }
  }

  Document operator +(Document doc) => new _Concat(this, doc);
  Document operator |(Document doc) => new _Or(this, doc);
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
          _Line line = doc;
          if (flat) {
            sink.write(line.alternative);
            numChars += line.alternative.length;
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
        case _DocType.OR:
          _Or group = doc;
          if (_fits(width - numChars, tail.cons(level, true, group.doc1))) {
            stack = tail.cons(level, true, group.doc1);
          } else {
            stack = tail.cons(level, flat, group.doc2);
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

  const _Nil() : super._();

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Nil);
  }

  int get hashCode => "Nil".hashCode;

  String toString() => "Nil()";
}

class _Concat extends Document {
  final _DocType _type = _DocType.CONCAT;
  final Document left;
  final Document right;

  const _Concat(Document left, Document right)
      : super._()
      , this.left = left
      , this.right = right;

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Concat  && left == other.left && right == other.right);
  }

  int get hashCode {
    int result =  "Concat".hashCode;
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

  const _Nest(int n, Document doc)
      : super._()
      , this.n = n
      , this.doc = doc;

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Nest && n == other.n && doc == other.doc);
  }

  int get hashCode {
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

  const _Text(String str)
      : super._()
      , this.str = str;

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Text && str == other.str);
  }

  int get hashCode {
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
  final String alternative;

  const _Line(this.alternative) : super._();

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Line && alternative == other.alternative);
  }

  int get hashCode => "Line".hashCode;

  String toString() => "Line()";
}

class _Group extends Document {
  final _DocType _type = _DocType.GROUP;
  final Document doc;

  const _Group(Document doc)
      : super._()
      , this.doc = doc;

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Group && doc == other.doc);
  }

  int get hashCode {
    int result = "Group".hashCode;
    result = 31 * result + doc.hashCode;
    return result;
  }

  String toString() => "Group($doc)";

  _Group copy({Document doc}) {
    return new _Group((doc != null) ? doc : this.doc);
  }
}

class _Or extends Document {
  final _DocType _type = _DocType.OR;
  final Document doc1;
  final Document doc2;

  const _Or(this.doc1, this.doc2) : super._();

  bool operator ==(other) {
    return identical(this, other)
        || (other is _Or && doc1 == other.doc1 && doc2 == other.doc2);
  }

  int get hashCode {
    int result = "Or".hashCode;
    result = 31 * result + doc1.hashCode;
    result = 31 * result + doc2.hashCode;
    return result;
  }

  String toString() => "Or($doc1, $doc2)";
}

final Document empty = const _Nil();
Document text(String str) => new _Text(str);
Document lineOr(String alternative) => new _Line(alternative);
final Document line = const _Line(" ");
