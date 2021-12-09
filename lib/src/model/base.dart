
/// If you want to create your own model, please extend this class.
abstract class XPathNode {
  String? get name;

  String? get text;

  XPathNode? get parentNode;

  List<XPathNode> get childrenNode;

  Map<String, String> get attributes;
}

/// If you want to create your own model, please extend this class.
abstract class XPathElement extends XPathNode {
  XPathElement? get parent;

  List<XPathElement> get children;

  XPathElement? get nextElementSibling;

  XPathElement? get previousElementSibling;
}
