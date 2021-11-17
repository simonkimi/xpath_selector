import 'package:html/dom.dart';

import 'execute.dart';

extension XPathElement on Element {
  XPathResult queryXPath(String xpath) => XPath(this).query(xpath);
}
