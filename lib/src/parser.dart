import 'package:xpath_selector/src/reg.dart';
import 'package:xpath_selector/src/selector.dart';

import 'model/base.dart';
import 'reg.dart';

/// parse xpath selector
List<List<Selector>> parseSelectGroup(String xpath) {
  final combine = xpath.split('|');
  final selectorList = <List<Selector>>[];

  for (final _path in combine) {
    final path = _path.trim();
    final selectorSources = <String>[];
    final matches = RegExp("//|/").allMatches(path).toList();
    for (var index = 0; index < matches.length; index++) {
      if (index > 0) {
        selectorSources.add(
            path.substring(matches[index - 1].start, matches[index].start));
      }
      if (index == matches.length - 1) {
        selectorSources.add(path.substring(matches[index].start, path.length));
      }
    }
    selectorList.add(selectorSources.map(_parseSelector).toList());
  }
  return selectorList;
}

Selector _parseSelector(String input) {
  late String source;
  late SelectorType selectorType;
  if (input.startsWith('//')) {
    // descendant
    selectorType = SelectorType.descendant;
    source = input.substring(2);
  } else if (input.startsWith('/')) {
    // self
    selectorType = SelectorType.self;
    source = input.substring(1);
  } else {
    throw FormatException("'$input' is not a valid xpath query string");
  }

  final simpleSelector = _parseSimpleSelector(selectorType, source);
  if (simpleSelector != null) return simpleSelector;

  // Axis
  AxesAxis? axis;
  late String withoutAxis;
  if (source.contains('::')) {
    final pattern = source.split('::');
    if (pattern.length > 2) throw UnsupportedError('Not support multiple axis');
    axis = SelectorAxes.createAxis(pattern.first.trim());
    withoutAxis = pattern.last.trim();
  } else {
    withoutAxis = source;
  }

  // node-test
  final match = nodeTestWithPredicate.firstMatch(withoutAxis);
  if (match == null) {
    // without predicate
    return Selector(
        selectorType: selectorType,
        axes: SelectorAxes(
          axis: axis,
          nodeTest: withoutAxis,
        ));
  }

  var nodeTest = match.namedGroup('node')!;
  // special nodeTest
  if (nodeTest == '.') {
    axis = AxesAxis.self;
    nodeTest = '*';
  }
  if (nodeTest == '..') {
    axis = AxesAxis.parent;
    nodeTest = '*';
  }

  // with predicate
  return Selector(
      selectorType: selectorType,
      axes: SelectorAxes(
        nodeTest: nodeTest,
        axis: axis,
        predicate: match.namedGroup('predicate')!,
      ));
}

Selector? _parseSimpleSelector(SelectorType selectorType, String source) {
  // attr
  if (source.startsWith('@')) {
    return Selector(
        selectorType: selectorType,
        axes: SelectorAxes(
          axis: AxesAxis.self,
          nodeTest: '*',
        ),
        attr: source.substring(1));
  }

  // parents
  if (source == '..') {
    return Selector(
        selectorType: selectorType,
        axes: SelectorAxes(
          axis: AxesAxis.parent,
          nodeTest: '*',
        ));
  }

  // self
  if (source == '.') {
    return Selector(
        selectorType: selectorType,
        axes: SelectorAxes(
          axis: AxesAxis.self,
          nodeTest: '*',
        ));
  }

  // node()
  if (source == 'node()') {
    return Selector(
      selectorType: selectorType,
      axes: SelectorAxes(
        nodeTest: 'node()',
        axis: AxesAxis.child,
      ),
    );
  }

  // text()
  final function = RegExp(r'^\w*\(\s*\)$').firstMatch(source);
  if (function != null) {
    return Selector(
      selectorType: selectorType,
      function: function.group(0),
      axes: SelectorAxes(
        nodeTest: '*',
        axis: AxesAxis.self,
      ),
    );
  }
}

/// if last selector is @attr or function, add to result
List<String?> parseAttr({
  required List<Selector> selectorList,
  required List<XPathNode> elements,
}) {
  final result = <String?>[];

  if (selectorList.isNotEmpty) {
    final lastSelector = selectorList.last;
    for (final element in elements) {
      if (lastSelector.attr != null) {
        // @attr
        if (lastSelector.attr == '*') {
          result.addAll(element.attributes.values);
        } else {
          result.add(element.attributes[lastSelector.attr]);
        }
      } else if (lastSelector.function != null) {
        // function
        result.add(
            elementFunction(node: element, function: lastSelector.function!));
      } else if (lastSelector.axes.axis == AxesAxis.attribute) {
        // attr
        if (lastSelector.axes.nodeTest == '*') {
          result.addAll(element.attributes.values);
        } else {
          result.add(element.attributes[lastSelector.axes.nodeTest]);
        }
      }
    }
  }
  return result;
}

/// if node-test is text() or other functions
String? elementFunction({required XPathNode node, required String function}) {
  if (function.startsWith('@')) {
    return node.attributes[function.substring(1)];
  } else {
    switch (function) {
      case 'text()':
      case 'string()':
        return node.text ?? '';
      case 'name()':
      case 'qualified()':
        return node.name?.qualified;
      case 'local-name()':
        return node.name?.localName;
      case 'namespace()':
      case 'prefix()':
        return node.name?.namespace;
      default:
        throw ArgumentError('Unknown function: $function');
    }
  }
}
