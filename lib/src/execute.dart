import 'package:html/dom.dart';
import 'package:html_xpath_selector/src/dom_selector.dart';
import 'package:html_xpath_selector/src/selector.dart';

class SelectorExecute {
  final result = <Element>[];
  var tmp = <Element>[];

  SelectorExecute({required this.root});

  final Element root;

  List<Element> execute(List<Selector> selectorList) {
    result.clear();
    tmp.clear();
    tmp.add(root);

    for (final selector in selectorList) {
      switch (selector.selectorType) {
        case SelectorType.self:
          _selfSelector();
          break;
        case SelectorType.child:
          // TODO: Handle this case.
          break;
        case SelectorType.descendant:
          // TODO: Handle this case.
          break;
      }
    }
    return result;
  }


  void _selfSelector() {

  }

  void _descendantSelector(Selector selector) {
    final newTmp = <Element>[];
    for (final t in tmp) {  // 以这个t为节点, 向下找
      final axisList = <Element>[];
      switch(selector.axes.axis ?? AxesAxis.descendant) {
        case AxesAxis.ancestor:
          axisList.addAll(ancestor(t));
          break;
        case AxesAxis.ancestorOrSelf:
          axisList.addAll(ancestor(t));
          axisList.add(t);
          break;
        case AxesAxis.child:
          axisList.addAll(t.children);
          break;
        case AxesAxis.following:
          // TODO: Handle this case.
          break;
        case AxesAxis.parent:
          if (t.parent != null) {
            axisList.add(t.parent!);
          }
          break;
        case AxesAxis.preceding:
          // TODO: Handle this case.
          break;
        case AxesAxis.precedingSibling:
          // TODO: Handle this case.
          break;
        case AxesAxis.self:
          // TODO: Handle this case.
          break;
        case AxesAxis.descendant:
        case AxesAxis.descendantOrSelf:
        // TODO: Handle this case.
          break;
      }

    }
  }
}
