import 'package:html/dom.dart';
import 'package:xml/xml.dart';

abstract class XPathNode {
  String? get text;

  XPathNode? get parentNode;

  List<XPathNode> get childrenNode;

  Map<String, String> get attributes;
}

abstract class XPathElement extends XPathNode {
  String? get name;

  XPathElement? get parent;

  List<XPathElement> get children;

  XPathElement? get nextElementSibling;

  XPathElement? get previousElementSibling;
}

class XmlNodeTree implements XPathNode {
  XmlNodeTree(this._node);

  static XmlNodeTree? buildNullNode(XmlNode? node) => node == null
      ? null
      : node is XmlElement
          ? XmlElementTree(node)
          : XmlNodeTree(node);

  static XmlNodeTree buildNode(XmlNode node) =>
      node is XmlElement ? XmlElementTree(node) : XmlNodeTree(node);

  final XmlNode _node;

  @override
  Map<String, String> get attributes => {};

  @override
  List<XPathNode> get childrenNode =>
      _node.children.map((child) => XmlNodeTree.buildNode(child)).toList();

  @override
  XPathNode? get parentNode => XmlNodeTree.buildNullNode(_node.parent);

  @override
  String? get text => _node.text;

  @override
  bool operator ==(Object other) =>
      other is XmlNodeTree ? other._node == _node : false;

  @override
  int get hashCode => _node.hashCode;

  XmlNode get node => _node;

  @override
  String toString() => _node.toString();
}

class XmlElementTree extends XmlNodeTree implements XPathElement {
  XmlElementTree(this._element) : super(_element);

  XmlElementTree? buildNullElement(XmlElement? element) =>
      element != null ? XmlElementTree(element) : null;

  final XmlElement _element;

  @override
  List<XPathElement> get children =>
      _element.childElements.map((child) => XmlElementTree(child)).toList();

  @override
  String? get name => _element.name.local;

  @override
  XPathElement? get nextElementSibling =>
      buildNullElement(_element.nextElementSibling);

  @override
  XPathElement? get parent => buildNullElement(_element.parentElement);

  @override
  XPathElement? get previousElementSibling =>
      buildNullElement(_element.previousElementSibling);

  @override
  bool operator ==(Object other) =>
      other is XmlElementTree ? other._element == _element : false;

  @override
  int get hashCode => _element.hashCode;

  XmlElement get element => _element;

  @override
  String toString() => _element.toString();

  @override
  Map<String, String> get attributes => Map.fromEntries(
      _element.attributes.map((e) => MapEntry(e.name.local, e.value)));
}

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
