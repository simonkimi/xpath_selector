import 'package:html/dom.dart';

import 'execute.dart';

extension XPathElement on Element {
  /// XPath query
  XPathResult queryXPath(String xpath) => XPath(this).query(xpath);
}
