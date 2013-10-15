// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Rafael Brandão (rafa.bra@gmail.com)

library pretty_extras;

import 'pretty.dart';
export 'pretty.dart';


const int _DEFAULT_INDENTATION = 2;

final Document space = text(' '),
               comma = text(','),
               colon = text(':'),
               openingBrace = text('{'),
               closingBrace = text('}'),
               emptyMap = openingBrace + closingBrace,
               openingBracket = text('['),
               closingBracket = text(']'),
               emptyList = openingBracket + closingBracket,
               doubleQuotes = text('"'),
               nullText = text('null');


Iterable<Document> _joinMap(Map<Object, Document> map, bool jsonComply) {
  List<Document> result = <Document>[];
  map.forEach((Object key, Document value) {
    final keyText =
        jsonComply
            ? (doubleQuotes + text('$key') + doubleQuotes + colon)
            : text('$key') + colon + space;
    result.add(keyText +  value);
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


Document _prettyMap(Map<Object, Document> map, int indentation,
                    bool jsonComply) =>
  _enclose(_joinMap(map, jsonComply), openingBrace, closingBrace, emptyMap,
      indentation);


Document _prettyList(Iterable<Document> list, int indentation) =>
  _enclose(list, openingBracket, closingBracket, emptyList, indentation);


Document _prettyObject(Object value, int indentation,
                      [bool jsonComply = false]) {

  if (value is Document) {
    return value;
  }
  if(value is Pretty) {
    return (value as Pretty).pretty;
  }
  if (value is Iterable) {
    final documentList = (value as Iterable).map((v) =>
        _prettyObject(v, indentation, jsonComply)
    );
    return _prettyList(documentList, indentation);
  }
  if (value is Map<Object, Object>) {
    final map = value as Map<Object, Object>,
          values =
              map.values.map((v) => _prettyObject(v, indentation, jsonComply)),
          documentMap = new Map.fromIterables(map.keys, values);

    return _prettyMap(documentMap, indentation, jsonComply);
  }
  final valueText = text('$value');
  if(!jsonComply) {
    return value != null ? valueText : empty;
  }
  return
      value != null
          ? ((value is bool) || (value is num))
              ? valueText
              : (doubleQuotes + valueText + doubleQuotes)
          : nullText;
}


Document prettyJson(Map<Object, Object> map,
                  {int indentation: _DEFAULT_INDENTATION}) =>
  _prettyObject(map, indentation, true);


Document prettyMap(Map<Object, Object> map,
                  {int indentation: _DEFAULT_INDENTATION}) =>
  _prettyObject(map, indentation);


Document prettyList(Iterable list,
                    {int indentation: _DEFAULT_INDENTATION}) =>
  _prettyObject(list, indentation);


Document prettyTree(String name, Iterable<Document> iterable,
                    {int indentation: _DEFAULT_INDENTATION}) =>
  text(name) + _enclose(iterable,
      (space + openingBrace), closingBrace, empty, indentation);


abstract class Pretty {
  Document get pretty;

  String render([int width = 0]) => pretty.group.render(width);

  String toString() => render();
}
