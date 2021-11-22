import 'package:xpath_selector/src/reg.dart';
import 'package:xpath_selector/src/selector.dart';

import 'model/base.dart';
import 'reg.dart';

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

  // text()
  if (source == 'text()') {
    return Selector(
      selectorType: selectorType,
      function: SelectorFunction.text,
      axes: SelectorAxes(
        nodeTest: '*',
        axis: AxesAxis.self,
      ),
    );
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
}

List<String?> parseAttr({
  required List<Selector> selectorList,
  required List<XPathNode> elements,
}) {
  final result = <String?>[];
  if (selectorList.isNotEmpty) {
    final last = selectorList.last;
    for (final element in elements) {
      if (last.attr != null) {
        if (last.attr == '*') {
          result.addAll(element.attributes.values);
        } else {
          result.add(element.attributes[last.attr]);
        }
      } else if (last.function == SelectorFunction.text) {
        result.add(element.text);
      } else if (last.axes.axis == AxesAxis.attribute) {
        if (last.axes.nodeTest == '*') {
          result.addAll(element.attributes.values);
        } else {
          result.add(element.attributes[last.axes.nodeTest]);
        }
      }
    }
  }
  return result;
}
