import 'package:html/dom.dart';
import 'builder.dart';

extension ElementHelper on Element {
  /// XPath query
  XPathResult queryXPath(String xpath) => XPath.htmlElement(this).query(xpath);
}
