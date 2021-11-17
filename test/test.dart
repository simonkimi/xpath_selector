import 'package:html/parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:xpath_for_html/src/dom_selector.dart';
import 'package:xpath_for_html/xpath_for_html.dart';


final String htmlString = '''
<html lang="en">
<body>
<div><a href='https://github.com/simonkimi'>author</a></div>
<div class="head">div head</div>
<div class="container">
    <table>
        <tbody>
          <tr>
              <td id="td1" class="first1">1</td>
              <td id="td2" class="first1">2</td>
              <td id="td3" class="first2">3</td>
              <td id="td4" class="first2 form">4</td>
              
              <td id="td5" class="second1">one</td>
              <td id="td6" class="second1">two</td>
              <td id="td7" class="second2">three</td>
              <td id="td8" class="second2">four</td>
          </tr>
        </tbody>
    </table>
</div>
<div class="end">end</div>

</body>
</html>
''';

final html = parse(htmlString).documentElement!;


void main() {
  test('basic', () {
    expect(html.queryXPath('//div/a').element, html.querySelector('a'));
    expect(html.queryXPath('//div/a/@href').attr, html.querySelector('a')!.attributes['href']);
    expect(html.queryXPath('//div/a/text()').attr, html.querySelector('a')!.text);
    expect(html.queryXPath('//tr/node()').elements, html.querySelector('tr')!.children);
  });

  test('simple predicate', () {
    expect(html.queryXPath('//tr/td[1]').element, html.querySelector('#td1'));
    expect(html.queryXPath('//tr/td[last()]').element, html.querySelector('#td8'));
    expect(html.queryXPath('//tr/td[last()-1]').element, html.querySelector('#td7'));
    expect(html.queryXPath('//tr/td[position()<3]').elements, [html.querySelector('#td1'), html.querySelector('#td2')]);
    expect(html.queryXPath('//tr/td[position() < 3]').elements, [html.querySelector('#td1'), html.querySelector('#td2')]);
  });

  test('complex predicate', () {
    expect(html.queryXPath('//tr/td[position() >= 2 and @class="second1"]').elements, [html.querySelector('#td5'), html.querySelector('#td6')]);
    expect(html.queryXPath('//tr/td[position() >= 2 and position() < 4]').elements, [html.querySelector('#td2'), html.querySelector('#td3')]);
    expect(html.queryXPath('//tr/td[position() <= 1 or position() >= 8]').elements, [html.querySelector('#td1'), html.querySelector('#td8')]);
  });

  test('extend predicate', () {
    expect(html.queryXPath('//tr/td[@class="first1"]').elements, html.querySelectorAll('td[class="first1"]'));
    expect(html.queryXPath('//tr/td[@class^="fir"]').elements, html.querySelectorAll('td[class^="fir"]'));
    expect(html.queryXPath('//tr/td[@class~="form"]').elements, html.querySelectorAll('td[class~="form"]'));
    expect(html.queryXPath(r'//tr/td[@class$="1"]').elements, html.querySelectorAll(r'td[class$="1"]'));
  });
  
  test('combination query', () {
    expect(html.queryXPath('//div/a|//div[@class="head"]').elements, [html.querySelector('a'), html.querySelector('.head')]);
    expect(html.queryXPath('//div/a | //div[@class="head"]').elements, [html.querySelector('a'), html.querySelector('.head')]);
  });

  test('axes', () {
    expect(html.queryXPath('//td/parent::*').element, html.querySelector('tr'));
    expect(html.queryXPath('//tr/child::*').elements, html.querySelectorAll('td'));
    expect(html.queryXPath('//td/ancestor::*').elements, ancestor(html.querySelector('td')));
    expect(html.queryXPath('//tr/ancestor-or-self::*').elements, ancestorOrSelf(html.querySelector('tr')));
    expect(html.queryXPath('//table/descendant::td').elements, html.querySelectorAll('td'));
    expect(html.queryXPath('//table//tbody/descendant-or-self::*').elements, [html.querySelector('tbody'), html.querySelector('tr'), ...html.querySelectorAll('td')]);
  });
}
