import '../model/base.dart';

/// Select top element
XPathNode? top(XPathNode? e) {
  if (e == null) return null;
  while (e!.parentNode != null) {
    e = e.parentNode!;
  }
  return e;
}

/// Selects all ancestors (parent, grandparent, etc.) of the current node
List<XPathNode> ancestor(XPathNode? e) {
  final result = <XPathNode>[];
  if (e == null) return result;
  var currentDom = e;

  while (currentDom.parentNode != null) {
    if (currentDom.parentNode! is XPathElement) {
      result.add(currentDom.parentNode!);
    }
    currentDom = currentDom.parentNode!;
  }
  return result;
}

/// Selects all ancestors (parent, grandparent, etc.) of the current node and the current node itself
List<XPathNode> ancestorOrSelf(XPathNode? e) {
  if (e == null) return <XPathNode>[];
  return <XPathNode>[e, ...ancestor(e)];
}

/// Selects all children of the current node
List<XPathNode> child(XPathNode? e) => e?.childrenNode ?? [];

/// Selects all descendants (children, grandchildren, etc.) of the current node
List<XPathNode> descendant(XPathNode? e) {
  final result = <XPathNode>[];
  if (e == null) return result;
  for (final child in e.childrenNode) {
    result.add(child);
    result.addAll(descendant(child));
  }
  return result;
}

/// Selects all descendants (children, grandchildren, etc.) of the current node and the current node itself
List<XPathNode> descentOrSelf(XPathNode? e) {
  if (e == null) return <XPathNode>[];
  return <XPathNode>[e, ...descendant(e)];
}

/// Selects everything in the document after the closing tag of the current node
List<XPathNode> following(XPathNode root, XPathNode? e) {
  final result = <XPathNode>[];
  var elementFound = false;

  void dfs(XPathNode parent) {
    for (final child in parent.childrenNode) {
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
List<XPathElement> followingSibling(XPathElement? e) {
  final result = <XPathElement>[];
  if (e == null) return result;
  var currentDom = e;
  while (currentDom.nextElementSibling != null) {
    result.add(currentDom.nextElementSibling!);
    currentDom = currentDom.nextElementSibling!;
  }
  return result;
}

/// Selects all siblings before the current node
List<XPathElement> precedingSibling(XPathElement? e) {
  final result = <XPathElement>[];
  if (e == null) return result;
  var currentDom = e;
  while (currentDom.previousElementSibling != null) {
    result.add(currentDom.previousElementSibling!);
    currentDom = currentDom.previousElementSibling!;
  }
  return result;
}
