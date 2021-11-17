int opNum(int a, int b, String op) {
  switch (op) {
    case '+':
      return a + b;
    case '-':
      return a - b;
    case '*':
      return a * b;
    case '/':
      return a ~/ b;
    case '%':
      return a % b;
    default:
      throw 'Unknown operator: $op';
  }
}

bool opCompare(int a, int b, String op) {
  switch (op) {
    case '<':
      return a < b;
    case '<=':
      return a <= b;
    case '>':
      return a > b;
    case '>=':
      return a >= b;
    case '==':
      return a == b;
    case '!=':
      return a != b;
    default:
      throw 'Unknown operator: $op';
  }
}
