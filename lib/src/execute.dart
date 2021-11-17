import 'dart:math';

import 'package:html/dom.dart';
import 'package:html_xpath_selector/src/dom_selector.dart';
import 'package:html_xpath_selector/src/selector.dart';
import 'package:html_xpath_selector/src/utils.dart';

import 'match.dart';

class SelectorExecute {
  final result = <Element>[];

  SelectorExecute({required this.root});

  final Element root;

  List<Element> execute(List<Selector> selectorList) {
    result.clear();
    for (final selector in selectorList) {}
    return result;
  }

  // 根据头部选择器确定初选范围
  List<Element> _matchSelectPath(Selector selector, Element element) {
    final waitingSelect = <Element>{};
    switch (selector.selectorType) {
      case SelectorType.child:
        waitingSelect.addAll(element.children);
        break;
      case SelectorType.descendant:
        waitingSelect.addAll(descendant(element));
        break;
      case SelectorType.self:
        waitingSelect.add(element);
        break;
    }
    return waitingSelect.toList();
  }

  // 确定一个Element是否符合Selector的node-test和predicate
  bool _matchSelector(Selector selector, Element element) {
    if (selector.attr != null) return true;
    // node-test
    final nodeTest = selector.axes.nodeTest;
    if (nodeTest != '*' && element.localName != nodeTest) return false;

    // predicates

    return true;
  }

  bool _matchPredicates(
      {required Selector selector,
      required Element element,
      required int position,
      required int length}) {
    if (selector.axes.predicates == null) return true;
    var predicates = selector.axes.predicates!;
    predicates = predicates.replaceAll(' and ', ' && ');
    predicates = predicates.replaceAll(' or ', ' || ');
    predicates = predicates.replaceAll(' div ', ' / ');
    predicates = predicates.replaceAll(' mod ', ' % ');



    if (predicateLast.hasMatch(predicates) ||
        predicateInt.hasMatch(predicates) ||
        predicatePosition.hasMatch(predicates)) {
      // Position
      if (predicateMultiple.hasMatch(predicates)) {
        // 多计算

      } else {
        // 单计算

      }
    }


    return false;
  }

  bool _singlePosition({
    required String predicates,
    required Element element,
    required int position,
    required int length,
  }) {
    final positionReg = simplePosition.firstMatch(predicates);
    if (positionReg != null) {
      final op = positionReg.namedGroup('op')!;
      final num = int.tryParse(positionReg.namedGroup('num')!) ?? 0;
      return opCompare(position + 1, num, op);
    }

    final lastReg = simpleLast.firstMatch(predicates);
    if (lastReg != null) {
      final num = int.tryParse(lastReg.namedGroup('num')!) ?? 0;
      final op = lastReg.namedGroup('op')!;
      return opNum(length, num, op) == position + 1;
    }

    final indexReg = predicateInt.firstMatch(predicates);
    if (indexReg != null) {
      final num = int.tryParse(indexReg.namedGroup('num')!) ?? 0;
      return num == position + 1;
    }
    return false;
  }
}
