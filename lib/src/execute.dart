import 'dart:html';

import 'package:html_xpath_selector/src/selector.dart';

class SelectorExecute {
  SelectorExecute({required this.root});

  final Element root;

  List<Element> execute(List<Selector> selectorList) {
    final result = <Element>[];
    final tmp = <Element>[];


    for (final selector in selectorList) {



    }


    return result;
  }
}
