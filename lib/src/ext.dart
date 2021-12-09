import 'package:html/dom.dart';
import 'package:xml/xml.dart';
import 'builder.dart';

extension ElementHelper on Element {
  /// Html XPath query
  XPathResult<Node> queryXPath(String xpath) =>
      XPath.htmlElement(this).query(xpath);
}

extension XmlElementHelper on XmlElement {
  /// Xml XPath query
  XPathResult<XmlNode> queryXPath(String xpath) =>
      XPath.xmlElement(this).query(xpath);
}
