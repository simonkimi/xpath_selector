import 'package:xml/xml.dart';
import 'base.dart';

/// Built-in xml model.
class XmlNodeTree extends XPathNode<XmlNode> {
  XmlNodeTree(XmlNode node) : super(node);

  static XmlNodeTree? from(XmlNode? node) {
    if (node == null) return null;
    return XmlNodeTree(node);
  }

  @override
  bool get isElement => node is XmlElement;

  @override
  Map<String, String> get attributes => Map.fromEntries(
      node.attributes.map((e) => MapEntry(e.name.qualified, e.value)));

  @override
  List<XmlNodeTree> get children =>
      node.children.map((child) => XmlNodeTree(child)).toList();

  @override
  XmlNodeTree? get parent => from(node.parent);

  @override
  String? get text => node.text;

  @override
  bool operator ==(Object other) =>
      other is XmlNodeTree ? other.node == node : false;

  @override
  int get hashCode => node.hashCode;

  @override
  NodeTagName? get name =>
      isElement ? NodeTagName.from((node as XmlElement).name.qualified) : null;

  @override
  String toString() => node.toString();

  @override
  XmlNodeTree? get nextSibling => from(node.nextElementSibling);

  @override
  XmlNodeTree? get previousSibling => from(node.previousSibling);
}
