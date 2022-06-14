import 'package:xml/xml.dart';
import 'package:xpath_selector/xpath_selector.dart';
import 'package:xpath_selector_xml_parser/xpath_selector_xml_parser.dart';

extension HtmlElementHelper on XmlNode {
  /// Xml XPath query
  XPathResult<XmlNode> queryXPath(String xpath) =>
      XmlXPath.node(this).query(xpath);
}

class XmlXPath extends XPath<XmlNode> {
  XmlXPath(XPathNode<XmlNode> root) : super(root);

  /// Create query by xml string
  static XmlXPath xml(String xml) {
    final dom = XmlDocument.parse(xml).rootElement;
    return XmlXPath(XmlNodeTree(dom));
  }

  /// Create query by xml node
  static XmlXPath node(XmlNode node) => XmlXPath(XmlNodeTree(node));
}
