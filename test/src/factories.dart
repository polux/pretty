// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library factories;

import 'package:pretty/pretty.dart' as implem;
import 'model.dart' as model;

abstract class DocumentFactory {
  implem.Document empty;
  implem.Document line;
  implem.Document text(String str);
}

class ImplemFactory extends DocumentFactory {
  implem.Document empty = implem.empty;
  implem.Document line = implem.line;
  implem.Document text(String str) => implem.text(str);
}

class ModelFactory extends DocumentFactory {
  implem.Document empty = model.empty;
  implem.Document line = model.line;
  implem.Document text(String str) => model.text(str);
}

final implemFactory = new ImplemFactory();
final modelFactory = new ModelFactory();
