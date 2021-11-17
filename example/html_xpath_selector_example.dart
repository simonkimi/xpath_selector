import 'package:expressions/expressions.dart';
import 'package:html/dom.dart';
import 'package:html_xpath_selector/src/execute.dart';
import 'package:html_xpath_selector/src/match.dart';
import 'package:html/parser.dart';
import 'package:html_xpath_selector/src/op.dart';
import 'package:html_xpath_selector/src/parser.dart';

void main() {
  final String html = '''
<html lang="en">
<body>
<div><a href='https://github.com'>github.com</a></div>
<div class="head">div head</div>
<div class="container">
    <table>
        <tbody>
          <tr>
              <td class="test1">1</td>
              <td class="test2">2</td>
              <td class="test3">3</td>
              <td class="test4">4</td>
          </tr>
        </tbody>
    </table>
</div>
<div class="end">end</div>

</body>
</html>
''';


}
