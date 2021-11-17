import 'package:expressions/expressions.dart';
import 'package:html/dom.dart';
import 'package:html_xpath_selector/src/dom_selector.dart';
import 'package:html_xpath_selector/src/selector.dart';
import 'package:tuple/tuple.dart';

import 'match.dart';
import 'op.dart';

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

    // predicate

    return true;
  }

  bool _matchPredicates(
      {required Selector selector,
      required Element element,
      required int position,
      required int length}) {
    if (selector.axes.predicate == null) return true;
    var predicate = selector.axes.predicate!;
    predicate = predicate.replaceAll(' and ', ' && ');
    predicate = predicate.replaceAll(' or ', ' || ');
    predicate = predicate.replaceAll(' div ', ' / ');
    predicate = predicate.replaceAll(' mod ', ' % ');

    if (predicateSym.allMatches(predicate).length >= 2 ||
        predicate.contains(' && ') ||
        predicate.contains(' || ')) {
      // 多计算
      return _multipleCompare(
        predicate: predicate,
        element: element,
        position: position,
        length: length,
      );
    } else {
      // 单计算

      // Position
      if (predicateLast.hasMatch(predicate) ||
          predicateInt.hasMatch(predicate)) {
        return _singlePosition(
          predicate: predicate,
          position: position,
          length: length,
        );
      }

      // compare
      return _singleCompare(
        predicate: predicate,
        element: element,
        position: position,
        length: length,
      );
    }
  }

  bool _singlePosition({
    required String predicate,
    required int position,
    required int length,
  }) {
    // [last() - 1]
    final lastReg = simpleLast.firstMatch(predicate);
    if (lastReg != null) {
      final num = int.tryParse(lastReg.namedGroup('num')!) ?? 0;
      final op = lastReg.namedGroup('op')!;
      return opNum(length, num, op) == position + 1;
    }

    // [1]
    final indexReg = predicateInt.firstMatch(predicate);
    if (indexReg != null) {
      final num = int.tryParse(indexReg.namedGroup('num')!) ?? 0;
      return num == position + 1;
    }
    return false;
  }

  bool _multipleCompare({
    required String predicate,
    required Element element,
    required int position,
    required int length,
  }) {
    var expression = predicate;

    final positionReg = simplePosition.allMatches(predicate);
    for (final reg in positionReg) {
      final result = _positionMatch(position, reg)!;
      expression = expression.replaceAll(reg[0]!, result ? 'true' : 'false');
    }

    final attrReg = predicateAttr.allMatches(predicate);
    for (final reg in attrReg) {
      final result = _attrMatch(element, reg)!;
      expression = expression.replaceAll(reg[0]!, result ? 'true' : 'false');
    }

    final eval = Expression.parse(expression);
    final evaluator = const ExpressionEvaluator();
    final result = evaluator.eval(eval, {});
    if (result is bool) return result;
    return false;
  }

  bool _singleCompare({
    required String predicate,
    required Element element,
    required int position,
    required int length,
  }) {
    // [position() < 3]
    final positionReg = simplePosition.firstMatch(predicate);
    final positionResult = _positionMatch(position, positionReg);
    if (positionResult != null) return positionResult;

    // [@attr='gdd']
    final attrReg = predicateAttr.firstMatch(predicate);
    final attrResult = _attrMatch(element, attrReg);
    if (attrResult != null) return attrResult;

    return false;
  }

  bool? _positionMatch(int position, RegExpMatch? reg) {
    if (reg != null) {
      final op = reg.namedGroup('op')!;
      final num = int.tryParse(reg.namedGroup('num')!) ?? 0;
      return opCompare(position + 1, num, op);
    }
    return null;
  }

  bool? _attrMatch(Element element, RegExpMatch? reg) {
    if (reg != null) {
      final attrName = reg.namedGroup('attr')!;
      final op = reg.namedGroup('op')!;
      final value = reg.namedGroup('value')!;
      final attr = element.attributes[attrName];
      if (attr == null) return false;
      return opString(attr, value, op);
    }
    return null;
  }
}
