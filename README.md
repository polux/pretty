# Pretty-Printing Combinators

[![Build Status](https://drone.io/github.com/polux/pretty/status.png)](https://drone.io/github.com/polux/pretty/latest)

A Dart port of [Christian Lindig's strict
version](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.34.2200) of
[Wadler's pretty-printing
combinators](http://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf).
The present version deforests away the second intermediate tree of Lindig's
implementation, which should make it slightly more efficient.


This is what this library allows for:

```dart
class Tree {
  final String name;
  final List<Tree> children;
  Tree(this.name, this.children);

  Document get pretty => // see below
}

final someTree = new Tree("aaa",
    [new Tree("bbbbb",
        [new Tree("ccc", []),
         new Tree("dd", [])]),
    new Tree("eee", []),
    new Tree("ffff",
        [new Tree("gg", []),
         new Tree("hhh", []),
         new Tree("ii", [])])]);

void main() {
  for (int width in [100, 50, 20, 10]) {
    print(someTree.pretty.render(width));
    print("");
  }
}
```

Output:

```
aaa { bbbbb { ccc, dd }, eee, ffff { gg, hhh, ii } }

aaa {
  bbbbb { ccc, dd },
  eee,
  ffff { gg, hhh, ii }
}

aaa {
  bbbbb { ccc, dd },
  eee,
  ffff {
    gg,
    hhh,
    ii
  }
}

aaa {
  bbbbb {
    ccc,
    dd
  },
  eee,
  ffff {
    gg,
    hhh,
    ii
  }
}
```

The set of combinators exposed by the library helps defining `Tree`'s `pretty`
method:

```dart
Document get pretty => (text(name) + _brackets).group;

Document get _brackets {
  return children.isEmpty
      ? empty
      : text(" {") + (line + _prettyChildren).nest(2) + line + text("}");
}

Document get _prettyChildren {
  return (text(",") + line).join(children.map((c) => c.pretty));
}
```

More documentation is underway.
