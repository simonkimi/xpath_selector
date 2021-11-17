



import 'package:expressions/expressions.dart';

void main() {
  final expression = Expression.parse("2 ~/ 1");


  final evaluator = const ExpressionEvaluator();
  var r = evaluator.eval(expression, {});

  print(r);
}