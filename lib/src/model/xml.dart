import 'package:xml/xml.dart';

import 'base.dart';

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
  String? get name => null;

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
  String? get name => _element.name.qualified;

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
      _element.attributes.map((e) => MapEntry(e.name.qualified, e.value)));
}
