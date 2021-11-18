import 'package:html/dom.dart';
import 'package:xml/xml.dart';
import 'package:xpath_selector/src/model/html.dart';
import 'package:xpath_selector/src/model/xml.dart';
import 'builder.dart';

extension ElementHelper on Element {
  /// Html XPath query
  XPathResult queryXPath(String xpath) => XPath.htmlElement(this).query(xpath);
}

extension XmlElementHelper on XmlElement {
  /// Xml XPath query
  XPathResult queryXPath(String xpath) => XPath.xmlElement(this).query(xpath);
}

extension XmlDocumentHelper on XmlElementTree {
  /// Xml XPath query
  XPathResult queryXPath(String xpath) =>
      XPath.xmlElement(element).query(xpath);
}

extension HtmlDocumentHelper on HtmlElementTree {
  /// Xml XPath query
  XPathResult queryXPath(String xpath) =>
      XPath.htmlElement(element).query(xpath);
}
