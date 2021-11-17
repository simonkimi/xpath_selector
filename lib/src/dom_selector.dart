import 'package:html/dom.dart';

/// Select top element
Element? top(Element? e) {
  if (e == null) return null;
  while(e!.parent != null) {
    e = e.parent!;
  }
  return e;
}

/// Selects all ancestors (parent, grandparent, etc.) of the current node
List<Element> ancestor(Element? e) {
  final result = <Element>[];
  if (e == null) return result;
  var currentDom = e;

  while (currentDom.parent != null) {
    result.add(currentDom.parent!);
    currentDom = currentDom.parent!;
  }
  return result;
}

/// Selects all ancestors (parent, grandparent, etc.) of the current node and the current node itself
List<Element> ancestorOrSelf(Element? e) {
  if (e == null) return <Element>[];
  return <Element>[e, ...ancestor(e)];
}

/// Selects all children of the current node
List<Element> child(Element? e) => e?.children ?? [];

/// Selects all descendants (children, grandchildren, etc.) of the current node
List<Element> descendant(Element? e) {
  final result = <Element>[];
  if (e == null) return result;
  for (final child in e.children) {
    result.add(child);
    result.addAll(descendant(child));
  }
  return result;
}

/// Selects all descendants (children, grandchildren, etc.) of the current node and the current node itself
List<Element> descentOrSelf(Element? e) {
  if (e == null) return <Element>[];
  return <Element>[e, ...descendant(e)];
}

/// Selects everything in the document after the closing tag of the current node
List<Element> following(Element root, Element? e) {
  final result = <Element>[];
  var elementFound = false;

  void dfs(Element parent) {
    for (final child in parent.children) {
      if (child == e) {
        elementFound = true;
      }
      if (elementFound) {
        result.add(child);
      }
      dfs(child);
    }
  }

  dfs(root);
  return result;
}

/// Selects all siblings after the current node
List<Element> followingSibling(Element? e) {
  final result = <Element>[];
  if (e == null) return result;
  var currentDom = e;
  while (currentDom.nextElementSibling != null) {
    result.add(currentDom.nextElementSibling!);
    currentDom = currentDom.nextElementSibling!;
  }
  return result;
}

/// Selects all siblings before the current node
List<Element> precedingSibling(Element? e) {
  final result = <Element>[];
  if (e == null) return result;
  var currentDom = e;
  while (currentDom.previousElementSibling != null) {
    result.add(currentDom.previousElementSibling!);
    currentDom = currentDom.previousElementSibling!;
  }
  return result;
}
