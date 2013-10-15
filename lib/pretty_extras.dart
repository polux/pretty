// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Rafael Brandão (rafa.bra@gmail.com)

library pretty_extras;

import 'pretty.dart';
export 'pretty.dart';


const int _DEFAULT_INDENTATION = 2;

final Document space = text(' '),
               comma = text(','),
               openingBrace = text('{'),
               closingBrace = text('}'),
               emptyMap = openingBrace + closingBrace,
               openingBracket = text('['),
               closingBracket = text(']'),
               emptyList = openingBracket + closingBracket;


Iterable<Document> _joinMap(Map<Object, Document> map) {
  List<Document> result = <Document>[];
  map.forEach((Object key, Document value) {
    result.add(text('$key: ') + value);
  });
  return result;
}


Document _join(Iterable<Document> iterable) =>
  (iterable != null && !iterable.isEmpty)
      ? (comma + line).join(iterable.map((d) => d.group))
      : empty;


Document _enclose(Iterable<Document> iterable, Document open, Document close,
              Document emptyValue, int indentation) =>
  ((iterable != null && !iterable.isEmpty)
      ? open + (line + _join(iterable)).nest(indentation) + line +  close
      : emptyValue).group;


Document _prettyMap(Map<Object, Document> map, int indentation) =>
  _enclose(_joinMap(map), openingBrace, closingBrace, emptyMap, indentation);


Document _prettyList(Iterable<Document> list, int indentation) =>
  _enclose(list, openingBracket, closingBracket, emptyList, indentation);


Document _prettyObject(Object value, int indentation) {

  if (value is Document) {
    return value;
  }
  if(value is Pretty) {
    return (value as Pretty).pretty;
  }
  if (value is Iterable) {
    final documentList = (value as Iterable).map((v) =>
        _prettyObject(v, indentation)
    );
    return _prettyList(documentList, indentation);
  }
  if (value is Map<Object, Object>) {
    final map = value as Map<Object, Object>,
          values = map.values.map((v) => _prettyObject(v, indentation)),
          documentMap = new Map.fromIterables(map.keys, values);

    return _prettyMap(documentMap, indentation);
  }
  return value != null ? text(value.toString()) : empty;
}


abstract class Pretty {
  Document get pretty;

  String render([int width = 0]) => pretty.group.render(width);

  String toString() => render();

  int get indentation => _DEFAULT_INDENTATION;

  Document prettyMap(Map<Object, Object> map) => _prettyObject(map, indentation);

  Document prettyList(Iterable list) => _prettyObject(list, indentation);

  Document prettyTree(String name, Iterable<Document> iterable) =>
    text(name) + _enclose(iterable,
        (space + openingBrace), closingBrace, empty, indentation);
}
