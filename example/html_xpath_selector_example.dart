// import 'package:expressions/expressions.dart';
// import 'package:html_xpath_selector/html_xpath_selector.dart';
// import 'package:html_xpath_selector/src/parser.dart';
//
// void main() {
//   // final xpath = '//table//ancestor::book//td[position()>2]/text()';
//   //
//   // print(parseSelectGroup(xpath));
//
// }

import 'package:html_xpath_selector/src/dom_selector.dart';
import 'package:test/test.dart';
import 'package:html/parser.dart';

void main() {
  final String html = '''
<html lang="en">
<body>
<div><a href='https://github.com'>github.com</a></div>
<div class="head">div head</div>
<div class="table">
    <table>
        <tr>
            <td>1</td>
            <td>2</td>
            <td>3</td>
            <td>4</td>
        </tr>
    </table>
</div>
<div class="end">end</div>

</body>
</html>
''';

  final p = parse(html);
  final root = p.documentElement!;

  final table = root.querySelector('table')!;

  print(table.localName);
}
