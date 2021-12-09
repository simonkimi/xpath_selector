import 'base.dart';
import 'package:html/dom.dart';

/// Built-in html model.
class HtmlNodeTree extends XPathNode<Node> {
  HtmlNodeTree(Node node) : super(node);

  static HtmlNodeTree? from(Node? node) {
    if (node == null) return null;
    return HtmlNodeTree(node);
  }

  @override
  bool get isElement => node is Element;

  @override
  HtmlNodeTree? get parent => from(node.parentNode);

  @override
  List<HtmlNodeTree> get children =>
      node.children.map((e) => HtmlNodeTree(e)).toList();

  @override
  HtmlNodeTree? get nextSibling =>
      isElement ? from((node as Element).nextElementSibling) : null;

  @override
  HtmlNodeTree? get previousSibling =>
      isElement ? from((node as Element).previousElementSibling) : null;

  @override
  Map<String, String> get attributes =>
      node.attributes.map((key, value) => MapEntry(key.toString(), value));

  @override
  String? get text => node.text;

  @override
  String toString() => node.toString();

  @override
  bool operator ==(Object other) =>
      other is HtmlNodeTree ? other.node == node : false;

  @override
  int get hashCode => node.hashCode;

  @override
  String? get name => isElement ? (node as Element).localName : null;
}
