// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Rafael de Andrade (rafa.bra@gmail.com)

library pretty_extras;

import 'pretty.dart';


const int _DEFAULT_INDENTATION = 2;

final Document space = text(' '),
               comma = text(','),
               openBrace = text('{'),
               closeBrace = text('}'),
               emptyMap = openBrace + space + closeBrace,
               openBracket = text('['),
               closeBracket = text(']'),
               emptyList = openBracket + closeBracket;


Iterable<Document> _joinMap(Map<String, Document> map) {

  String punctuateKey(String key) {
    key = key.trim();
    return key.endsWith(':') ? '$key' : '$key:';
  }

  List<Document> result = <Document>[];
  map.forEach((String key, Document value) {
    result.add(text(punctuateKey(key)) + space + value);
  });
  return result;
}


Document _join(Iterable<Document> iterable) =>
  (iterable != null && !iterable.isEmpty)
    ? (comma + line).join(iterable)
    : empty;


Document _enclose(Iterable<Document> iterable, Document open, Document close,
                 Document emptyValue, { int indentation: _DEFAULT_INDENTATION }) =>
  (iterable != null && !iterable.isEmpty)
    ? open + (line + _join(iterable)).nest(indentation) + line +  close
    : emptyValue;


Document map(Map<String, Document> map, { int indentation: _DEFAULT_INDENTATION }) =>
  _enclose(_joinMap(map), openBrace, closeBrace, emptyMap, indentation: indentation);


Document list(Iterable<Document> list, { int indentation: _DEFAULT_INDENTATION }) =>
  _enclose(list, openBracket, closeBracket, emptyList, indentation: indentation);


Document tree(String name, Iterable<Document> iterable,
                { int indentation: _DEFAULT_INDENTATION }) =>
  text(name) + _enclose(iterable, (space + openBrace), closeBrace, empty,
      indentation: indentation);


abstract class Pretty {
  Document get pretty;

  Document get group => pretty.group;

  String toString() => group.render(0);
}
