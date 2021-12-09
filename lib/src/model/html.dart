import 'base.dart';
import 'package:html/dom.dart';


/// Built-in html model.
class HtmlNodeTree implements XPathNode {
  HtmlNodeTree(this._node);

  static HtmlNodeTree? buildNullNode(Node? node) => node == null
      ? null
      : node is Element
          ? HtmlElementTree(node)
          : HtmlNodeTree(node);

  static HtmlNodeTree buildNode(Node node) =>
      node is Element ? HtmlElementTree(node) : HtmlNodeTree(node);

  final Node _node;

  @override
  HtmlNodeTree? get parentNode => buildNullNode(_node.parentNode);

  @override
  List<HtmlNodeTree> get childrenNode => _node.nodes.map(buildNode).toList();

  @override
  Map<String, String> get attributes =>
      _node.attributes.map((key, value) => MapEntry(key.toString(), value));

  @override
  String? get text => _node.text;

  @override
  String toString() => _node.toString();

  @override
  bool operator ==(Object other) =>
      other is HtmlNodeTree ? other._node == _node : false;

  @override
  int get hashCode => _node.hashCode;

  Node get node => _node;

  @override
  String? get name => null;
}

class HtmlElementTree extends HtmlNodeTree implements XPathElement {
  HtmlElementTree(this._element) : super(_element);

  HtmlElementTree? buildElement(Element? element) =>
      element != null ? HtmlElementTree(element) : null;

  final Element _element;

  @override
  XPathElement? get nextElementSibling =>
      buildElement(_element.nextElementSibling);

  @override
  XPathElement? get previousElementSibling =>
      buildElement(_element.previousElementSibling);

  @override
  String? get name => _element.localName;

  @override
  List<XPathElement> get children =>
      _element.children.map((e) => HtmlElementTree(e)).toList();

  @override
  XPathElement? get parent => buildElement(_element.parent);

  @override
  String toString() => _element.toString();

  @override
  bool operator ==(Object other) =>
      other is HtmlElementTree ? other._element == _element : false;

  @override
  int get hashCode => _element.hashCode;

  Element get element => _element;
}
