import 'package:expressions/expressions.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:xpath_for_html/src/dom_selector.dart';
import 'package:xpath_for_html/src/parser.dart';
import 'package:xpath_for_html/src/selector.dart';
import 'package:xpath_for_html/src/utils.dart';

import 'reg.dart';
import 'op.dart';

class XPathResult {
  XPathResult(this.elements, this.attrs);

  final List<Element> elements;
  final List<String?> attrs;

  Element? get element => elements.isNotEmpty ? elements.first : null;

  String? get attr => attrs.firstWhere((e) => e != null, orElse: () => null);
}

class XPath {
  /// Create XPath by html element
  XPath(this.root);

  /// Create XPath by html string
  factory XPath.html(String html) {
    final dom = parse(html).documentElement;
    if (dom == null) throw UnsupportedError('No html');
    return XPath(dom);
  }

  final Element root;

  /// query XPath
  XPathResult query(String xpath) {
    final result = <Element>[];
    final resultAttrs = <String?>[];
    final selectorGroup = parseSelectGroup(xpath);
    for (final selector in selectorGroup) {
      final newResult = _execute(selectorList: selector, element: root)
          .where((e) => !result.contains(e))
          .toList();
      result.addAll(newResult);
      resultAttrs.addAll(_parseAttr(
        selectorList: selector,
        elements: newResult.toList(),
      ));
    }
    return XPathResult(result, resultAttrs);
  }
}

List<String?> _parseAttr({
  required List<Selector> selectorList,
  required List<Element> elements,
}) {
  final result = <String?>[];
  if (selectorList.isNotEmpty) {
    final last = selectorList.last;
    for(final element in elements) {
      if (last.attr != null) {
        result.add(element.attributes[last.attr!]);
      } else if (last.function == SelectorFunction.text) {
        result.add(element.text);
      }
    }
  }
  return result;
}

List<Element> _execute({
  required List<Selector> selectorList,
  required Element element,
}) {
  var tmp = <Element>[element];

  for (final selector in selectorList) {
    final rootMatch = <Element>[];
    for (final element in tmp) {
      final pathElement = _matchSelectPath(selector, element);
      final selectorMatch = <Element>[];
      for (final element in pathElement) {
        final axisElement = _matchAxis(selector, element);
        final removeIndex = [];
        for (var i = 0; i < axisElement.length; i++) {
          final element = axisElement[i];
          if (!_matchSelector(
              selector: selector,
              element: element,
              position: i,
              length: axisElement.length)) {
            removeIndex.add(i);
          }
        }
        for (final index in removeIndex.reversed) {
          axisElement.removeAt(index);
        }
        selectorMatch.addAllIfNotExist(axisElement);
      }
      rootMatch.addAllIfNotExist(selectorMatch);
    }
    tmp = rootMatch;
  }
  return tmp;
}

/// Get element by path
List<Element> _matchSelectPath(Selector selector, Element element) {
  final waitingSelect = <Element>[];
  switch (selector.selectorType) {
    case SelectorType.descendant:
      waitingSelect.addAllIfNotExist(descentOrSelf(element));
      break;
    case SelectorType.self:
      waitingSelect.addIfNotExist(element);
      break;
  }
  print(waitingSelect);
  return waitingSelect;
}

/// Get element by Axis
List<Element> _matchAxis(Selector selector, Element element) {
  final waitingSelect = <Element>[];
  switch (selector.axes.axis) {
    case AxesAxis.child:
    case null:
      waitingSelect.addAllIfNotExist(element.children);
      break;
    case AxesAxis.ancestor:
      waitingSelect.addAllIfNotExist(ancestor(element));
      break;
    case AxesAxis.ancestorOrSelf:
      waitingSelect.addAllIfNotExist(ancestorOrSelf(element));
      break;
    case AxesAxis.descendant:
      waitingSelect.addAllIfNotExist(descendant(element));
      break;
    case AxesAxis.descendantOrSelf:
      waitingSelect.addAllIfNotExist(descentOrSelf(element));
      break;
    case AxesAxis.following:
      waitingSelect
          .addAllIfNotExist(following(top(element) ?? element, element));
      break;
    case AxesAxis.followingSibling:
      waitingSelect.addAllIfNotExist(followingSibling(element));
      break;
    case AxesAxis.parent:
      if (element.parent != null) waitingSelect.add(element.parent!);
      break;
    case AxesAxis.precedingSibling:
      waitingSelect.addAllIfNotExist(precedingSibling(element));
      break;
    case AxesAxis.self:
      waitingSelect.addIfNotExist(element);
      break;
  }
  return waitingSelect;
}

/// Is element match [Selector]'s [selector.axes.nodeTest] and [predicate]
bool _matchSelector({
  required Selector selector,
  required Element element,
  required int position,
  required int length,
}) {
  if (selector.attr != null) return true;
  // node-test
  final nodeTest = selector.axes.nodeTest;
  if (nodeTest != '*' && element.localName != nodeTest) return false;
  // predicate
  if (selector.axes.predicate != null) {
    return _matchPredicates(
      position: position,
      length: length,
      element: element,
      selector: selector,
    );
  }
  return true;
}

/// Is element match [selector.axes.predicate]
bool _matchPredicates({
  required Selector selector,
  required Element element,
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

bool? _childMatch(Element element, RegExpMatch? reg) {
  if (reg != null) {
    final childName = reg.namedGroup('child');
    final op = reg.namedGroup('op')!;
    final num = int.tryParse(reg.namedGroup('num')!) ?? 0;
    final childValue = element.children
        .where((e) => e.localName == childName)
        .map((e) => int.tryParse(e.text))
        .firstWhere((e) => e != null, orElse: () => null);
    if (childValue == null) return false;
    return opCompare(childValue, num, op);
  }
}
