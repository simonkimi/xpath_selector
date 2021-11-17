import 'package:expressions/expressions.dart';
import 'package:html/dom.dart';
import 'package:html_xpath_selector/src/match.dart';
import 'package:html/parser.dart';
import 'package:html_xpath_selector/src/op.dart';
import 'package:tuple/tuple.dart';

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
    expression = expression.replaceAll(reg[0]!, result ? 'true': 'false');
  }

  final attrReg = predicateAttr.allMatches(predicate);
  for (final reg in attrReg) {
    final result = _attrMatch(element, reg)!;
    expression = expression.replaceAll(reg[0]!, result ? 'true': 'false');
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
    print('$attr $value $op');
    return opString(attr, value, op);
  }
  return null;
}

void main() {
  final String html = '''
<html lang="en">
<body>
<div><a href='https://github.com'>github.com</a></div>
<div class="head">div head</div>
<div class="container">
    <table>
        <tr>
            <td class="test1">1</td>
            <td class="test2">2</td>
            <td class="test3">3</td>
            <td class="test4">4</td>
        </tr>
    </table>
</div>
<div class="end">end</div>

</body>
</html>
''';

  final dom = parse(html).documentElement!;

  final table = dom.querySelector('td')!;

  print(_multipleCompare(
    predicate: '@class^="te" && position() <= 1',
    element: table,
    length: 4,
    position: 1
  ));
}
