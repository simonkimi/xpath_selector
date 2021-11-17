import 'package:html/dom.dart';

import 'execute.dart';

extension XPathElement on Element {
  Element? queryXPath(String xpath) => XPath(this).query(xpath).element;

  List<Element> queryAllXPath(String xpath) =>
      XPath(this).query(xpath).elements;

  String? queryXPathAttr(String xpath) => XPath(this).query(xpath).attr;

  List<String> queryAllXPathAttr(String xpath) =>
      XPath(this).query(xpath).attrs.where((e) => e != null).toList().cast();

  XPathResult xpath(String xpath) => XPath(this).query(xpath);
}
