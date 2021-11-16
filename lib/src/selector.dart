enum SelectorType { child, root }

class SelectorGroup {
  final List<Selector> selectors;
  final String source;
  final String? output;

  SelectorGroup(this.selectors, this.output, this.source);
}

class Selector {
  Selector({required this.selectorType, required this.axes});

  final SelectorType selectorType;
  final SelectorAxes axes;

  @override
  String toString() =>
      '${selectorType == SelectorType.root ? '//' : '/'}${axes.axis?.toString() ?? ''}${axes.axis != null ? '::' : ''}${axes.nodeTest}${axes.predicates != null ? '[${axes.predicates}]' : ''}';
}

// 轴
enum AxesAxis {
  ancestor,
  ancestorOrSelf,
  child,
  descendant,
  descendantOrSelf,
  following,
  parent,
  preceding,
  precedingSibling,
  self,
}

class SelectorAxes {
  SelectorAxes({
    required this.axis,
    required this.nodeTest,
    this.predicates,
  });

  final AxesAxis? axis;
  final String nodeTest;
  final String? predicates;

  static AxesAxis createAxis(String axis) {
    final map = {
      'ancestor': AxesAxis.ancestor,
      'ancestor-or-self': AxesAxis.ancestorOrSelf,
      'child': AxesAxis.child,
      'descendant': AxesAxis.descendant,
      'descendant-or-self': AxesAxis.descendantOrSelf,
      'following': AxesAxis.following,
      'parent': AxesAxis.parent,
      'preceding': AxesAxis.preceding,
      'preceding-sibling': AxesAxis.precedingSibling,
      'self': AxesAxis.self,
    };
    if (!map.containsKey(axis)) {
      throw FormatException('not support axis: $axis');
    }
    return map[axis]!;
  }
}

abstract class SelectorPredicate {}

class IndexPredicate extends SelectorPredicate {}

class ExpressionPredicate extends SelectorPredicate {}
