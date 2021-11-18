import 'package:expressions/expressions.dart';
import 'package:xpath_selector/src/utils/dom_selector.dart';
import 'package:xpath_selector/src/selector.dart';
import 'package:xpath_selector/src/utils/utils.dart';
import 'model/base.dart';
import 'reg.dart';
import 'utils/op.dart';

List<XPathNode> execute({
  required List<Selector> selectorList,
  required XPathNode element,
}) {
  var tmp = <XPathNode>[element];

  for (final selector in selectorList) {
    final rootMatch = <XPathNode>[];
    for (final element in tmp) {
      final pathXPathNode = _matchSelectPath(selector, element);
      final selectorMatch = <XPathNode>[];
      for (final element in pathXPathNode) {
        final axisXPathNode = _matchAxis(selector, element);
        final removeIndex = [];

        // _matchSelector
        for (var i = 0; i < axisXPathNode.length; i++) {
          final element = axisXPathNode[i];
          if (!_matchSelector(
              selector: selector,
              element: element,
              position: i,
              length: axisXPathNode.length)) {
            removeIndex.add(i);
          }
        }
        for (final index in removeIndex.reversed) {
          axisXPathNode.removeAt(index);
        }
        removeIndex.clear();

        // matchPredicates
        for (var i = 0; i < axisXPathNode.length; i++) {
          final element = axisXPathNode[i];
          if (!_matchPredicates(
              selector: selector,
              element: element,
              position: i,
              length: axisXPathNode.length)) {
            removeIndex.add(i);
          }
        }
        for (final index in removeIndex.reversed) {
          axisXPathNode.removeAt(index);
        }

        selectorMatch.addAllIfNotExist(axisXPathNode);
      }
      rootMatch.addAllIfNotExist(selectorMatch);
    }
    tmp = rootMatch;
  }
  return tmp;
}

/// Get element by path
List<XPathNode> _matchSelectPath(Selector selector, XPathNode node) {
  final waitingSelect = <XPathNode>[];
  switch (selector.selectorType) {
    case SelectorType.descendant:
      waitingSelect.addAllIfNotExist(descentOrSelf(node));
      break;
    case SelectorType.self:
      waitingSelect.addIfNotExist(node);
      break;
  }
  return waitingSelect;
}

/// Get element by Axis
List<XPathNode> _matchAxis(Selector selector, XPathNode node) {
  final waitingSelect = <XPathNode>[];
  switch (selector.axes.axis) {
    case AxesAxis.child:
    case null:
      waitingSelect.addAllIfNotExist(node.childrenNode);
      break;
    case AxesAxis.ancestor:
      waitingSelect.addAllIfNotExist(ancestor(node));
      break;
    case AxesAxis.ancestorOrSelf:
      waitingSelect.addAllIfNotExist(ancestorOrSelf(node));
      break;
    case AxesAxis.descendant:
      waitingSelect.addAllIfNotExist(descendant(node));
      break;
    case AxesAxis.descendantOrSelf:
      waitingSelect.addAllIfNotExist(descentOrSelf(node));
      break;
    case AxesAxis.following:
      waitingSelect.addAllIfNotExist(following(top(node) ?? node, node));
      break;
    case AxesAxis.parent:
      if (node.parentNode != null) waitingSelect.add(node.parentNode!);
      break;
    case AxesAxis.followingSibling:
      if (node is XPathElement) {
        waitingSelect.addAllIfNotExist(followingSibling(node));
      }
      break;
    case AxesAxis.precedingSibling:
      if (node is XPathElement) {
        waitingSelect.addAllIfNotExist(precedingSibling(node));
      }
      break;
    case AxesAxis.attribute:
    case AxesAxis.self:
      waitingSelect.addIfNotExist(node);
      break;
  }
  return waitingSelect;
}

/// Is element match [Selector]'s [selector.axes.nodeTest] and [predicate]
bool _matchSelector({
  required Selector selector,
  required XPathNode element,
  required int position,
  required int length,
}) {
  if (selector.attr != null) return true;
  if (selector.axes.axis == AxesAxis.attribute) return true;

  // node-test
  final nodeTest = selector.axes.nodeTest;

  if (nodeTest != 'node()') {
    if (element is! XPathElement) {
      return false;
    }

    if (nodeTest != '*' && element.name != nodeTest) {
      return false;
    }
  }
  return true;
}

/// Is element match [selector.axes.predicate]
bool _matchPredicates({
  required Selector selector,
  required XPathNode element,
  required int position,
  required int length,
}) {
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
    if (predicateLast.hasMatch(predicate) || predicateInt.hasMatch(predicate)) {
      return _singlePosition(
        predicate: predicate,
        position: position,
        length: length,
      );
    }

    // Compare
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

  // [last()]
  final last = simpleSingleLast.firstMatch(predicate);
  if (last != null) {
    return length == position + 1;
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
  required XPathNode element,
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

  final childReg = predicateChild.allMatches(predicate);
  for (final reg in childReg) {
    final result = _childMatch(element, reg)!;
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
  required XPathNode element,
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

  // [child<10]
  final childReg = predicateChild.firstMatch(predicate);
  final childResult = _childMatch(element, childReg);
  if (childResult != null) return childResult;
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

bool? _attrMatch(XPathNode element, RegExpMatch? reg) {
  if (reg != null) {
    final attrName = reg.namedGroup('attr')!;
    final op = reg.namedGroup('op')!;
    final value = reg.namedGroup('value')!;
    final attr = element.attributes[attrName.trim()];
    if (attr == null) return false;
    return opString(attr, value, op);
  }
  return null;
}

bool? _childMatch(XPathNode element, RegExpMatch? reg) {
  if (reg != null) {
    final childName = reg.namedGroup('child');
    final op = reg.namedGroup('op')!;
    final num = int.tryParse(reg.namedGroup('num')!) ?? 0;
    final int? childValue = element.childrenNode
        .where((e) => e is XPathElement && e.name == childName)
        .map((e) => int.tryParse(e.text ?? ''))
        .firstWhere((e) => e != null, orElse: () => null);
    if (childValue == null) return false;
    return opCompare(childValue, num, op);
  }
}
