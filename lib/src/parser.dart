import 'package:html_xpath_selector/src/selector.dart';

import 'match.dart';

List<List<Selector>> parseSelectGroup(String xpath) {
  final combine = xpath.split('|');
  final selectorList = <List<Selector>>[];

  for (final path in combine) {
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
  if (input.startsWith('//')) {  // descendant
    selectorType = SelectorType.descendant;
    source = input.substring(2);
  } else if (input.startsWith('/')) {  // self
    selectorType = SelectorType.self;
    source = input.substring(1);
  } else if (input == '.') {
    return Selector(
        selectorType: SelectorType.self,
        axes: SelectorAxes(
          axis: AxesAxis.self,
          nodeTest: '*',
        ));
  } else {
    throw FormatException("'$input' is not a valid xpath query string");
  }

  if (source=='@') {
    return Selector(
      selectorType: selectorType,
      axes: SelectorAxes(
        axis: AxesAxis.self,
        nodeTest: '*',
      ),
      attr: source
    );
  }

  // 父节点
  if (source == '..') {
    return Selector(
        selectorType: selectorType,
        axes: SelectorAxes(
          axis: AxesAxis.parent,
          nodeTest: '*',
        ));
  }

  // 自己
  if (source == '.') {
    return Selector(
        selectorType: selectorType,
        axes: SelectorAxes(
          axis: AxesAxis.self,
          nodeTest: '*',
        ));
  }

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

  // with predicate
  return Selector(
      selectorType: selectorType,
      axes: SelectorAxes(
        nodeTest: match.namedGroup('node')!,
        axis: axis,
        predicate: match.namedGroup('predicate')!,
      ));
}
