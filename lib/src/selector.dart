enum SelectorType { descendant, self }

enum SelectorFunction { text, node }

class SelectorGroup {
  final List<Selector> selectors;
  final String source;
  final String? output;

  SelectorGroup(this.selectors, this.output, this.source);
}

class Selector {
  Selector({
    required this.selectorType,
    required this.axes,
    this.attr,
    this.function,
  });

  final SelectorType selectorType;
  final SelectorAxes axes;
  final String? attr;
  final SelectorFunction? function;

  @override
  String toString() =>
      '${selectorType == SelectorType.descendant ? '//' : '/'}${axes.axis?.toString() ?? ''}${axes.axis != null ? '::' : ''}${function ?? axes.nodeTest}${axes.predicate != null ? '[${axes.predicate}]' : ''}';
}

// 轴
enum AxesAxis {
  ancestor,
  ancestorOrSelf,
  child,
  descendant,
  descendantOrSelf,
  following,
  followingSibling,
  parent,
  precedingSibling,
  self,
  attribute,
}

class SelectorAxes {
  SelectorAxes({
    required this.axis,
    required this.nodeTest,
    this.predicate,
  });

  final AxesAxis? axis;
  final String nodeTest;
  final String? predicate;

  static AxesAxis createAxis(String axis) {
    final map = {
      'ancestor': AxesAxis.ancestor,
      'ancestor-or-self': AxesAxis.ancestorOrSelf,
      'child': AxesAxis.child,
      'descendant': AxesAxis.descendant,
      'descendant-or-self': AxesAxis.descendantOrSelf,
      'following': AxesAxis.following,
      'following-sibling': AxesAxis.followingSibling,
      'parent': AxesAxis.parent,
      'preceding-sibling': AxesAxis.precedingSibling,
      'self': AxesAxis.self,
      'attribute': AxesAxis.attribute,
    };
    if (!map.containsKey(axis)) {
      throw FormatException('not support axis: $axis');
    }
    return map[axis]!;
  }

  static SelectorFunction createFunction(String function) {
    final map = {
      'text()': SelectorFunction.text,
      'node()': SelectorFunction.node,
    };
    if (!map.containsKey(function)) {
      throw FormatException('not support axis: $function');
    }
    return map[function]!;
  }
}

abstract class SelectorPredicate {}

class IndexPredicate extends SelectorPredicate {}

class ExpressionPredicate extends SelectorPredicate {}
