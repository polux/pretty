// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Rafael de Andrade (rafa.bra@gmail.com)

library pretty_extras;

import 'pretty.dart';


const int _DEFAULT_IDENTATION = 2;

final Document space = text(' '),
               comma = text(','),
               openBrace = text('{'),
               closeBrace = text('}'),
               emptyMap = openBrace + space + closeBrace,
               openBracket = text('['),
               closeBracket = text(']'),
               emptyList = openBracket + closeBracket;

Iterable<Document> _joinMap(Map<String, Document> map) {

  String normalizeKey(String key) {
    key = key.trim();
    return key.endsWith(':') ? '$key' : '$key:';
  }

  List<Document> result = <Document>[];
  map.forEach((String key, Document value) {
    result.add(text(normalizeKey(key)) + space + value);
  });
  return result;
}


Document _join(Iterable<Document> iterable) =>
  (iterable != null && !iterable.isEmpty)
    ? (comma + line).join(iterable)
    : empty;


Document _format(Iterable<Document> iterable, Document open, Document close,
                 Document emptyValue, int identation) =>
  (iterable != null && !iterable.isEmpty)
    ? open + (line + _join(iterable)).nest(identation) + line +  close
    : emptyValue;


Document map(Map<String, Document> map, {int identation: _DEFAULT_IDENTATION }) =>
  _format(_joinMap(map), openBrace, closeBrace, emptyMap, identation);


Document list(Iterable<Document> list, {int identation: _DEFAULT_IDENTATION }) =>
  _format(list, openBracket, closeBracket, emptyList, identation);


Document tree(Iterable<Document> tree, {int identation: _DEFAULT_IDENTATION }) =>
  _format(tree, openBrace, closeBrace, empty, identation);


abstract class Pretty {
  Document get pretty;

  Document get prettyGroup => pretty.group;

  String toString() => prettyGroup.render(0);
}