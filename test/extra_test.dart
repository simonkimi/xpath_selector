import 'package:test/test.dart';
import 'package:xpath_selector/xpath_selector.dart';

void main() {
  group('attribute query', () {
    final xml =
        '<root><a id="task" href="https://google.com/"/><a id="12345678-1234-1234-1234-123456789012" href="https://github.com/"/></root>';

    test('a-zA-Z0-9', () {
      final evaluator = XPath.xml(xml);
      expect(evaluator.query(r'//a[@id="task"]').node, isNotNull);
    });

    test('contains -', () {
      final evaluator = XPath.xml(xml);
      expect(
          evaluator
              .query(r'//a[@id="12345678-1234-1234-1234-123456789012"]')
              .node,
          isNotNull);
    });

    test('contains /', () {
      final evaluator = XPath.xml(xml);
      expect(
          evaluator.query(r'//a[@href="https://google.com/"]').node, isNotNull);
    });
  });
}
