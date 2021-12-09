/// If you want to create your own model, please extend this class.
abstract class XPathNode<T> {
  XPathNode(this.node);

  T node;

  String? get name;

  String? get text;

  XPathNode<T>? get parent;

  List<XPathNode<T>> get children;

  Map<String, String> get attributes;

  XPathNode<T>? get nextSibling;

  XPathNode<T>? get previousSibling;

  bool get isElement;

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}
