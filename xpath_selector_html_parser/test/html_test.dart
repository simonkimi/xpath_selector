import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:xpath_selector/src/utils/dom_selector.dart';
import 'package:xpath_selector/xpath_selector.dart';

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

extension TestTransfer on Element {
  XPathNode? query(String selector) =>
      HtmlNodeTree.from(querySelector(selector));

  List<XPathNode> queryAll(String selector) =>
      querySelectorAll(selector).map((e) => HtmlNodeTree(e)).toList();
}

void main() {
  test('basic', () {
    expect(html.queryXPath('//div/a').node, html.query('a'));
    expect(html.queryXPath('//div/a/@href').attr,
        html.query('a')!.attributes['href']);
    expect(html.queryXPath('//td[@id="td1"]/@*').attrs,
        html.query('#td1')!.attributes.values);
    expect(html.queryXPath('//div/a/text()').attr, html.query('a')!.text);
    expect(html.queryXPath('//tr/node()').nodes, html.query('tr')!.children);
    expect(html.queryXPath('//tr/td[@class^="fir" and not(text()="4")]').nodes,
        [html.query('#td1'), html.query('#td2'), html.query('#td3')]);
  });

  test('simple predicate', () {
    expect(html.queryXPath('//tr/td[1]').node, html.query('#td1'));
    expect(html.queryXPath('//tr/td[last()]').node, html.query('#td8'));
    expect(html.queryXPath('//tr/td[last()-1]').node, html.query('#td7'));
    expect(html.queryXPath('//tr/td[position()<3]').nodes,
        [html.query('#td1'), html.query('#td2')]);
    expect(html.queryXPath('//tr/td[position() < 3]').nodes,
        [html.query('#td1'), html.query('#td2')]);
  });

  test('complex predicate', () {
    expect(
        html.queryXPath('//tr/td[position() >= 2 and @class="second1"]').nodes,
        [html.query('#td5'), html.query('#td6')]);
    expect(html.queryXPath('//tr/td[position() >= 2 and position() < 4]').nodes,
        [html.query('#td2'), html.query('#td3')]);
    expect(html.queryXPath('//tr/td[position() <= 1 or position() >= 8]').nodes,
        [html.query('#td1'), html.query('#td8')]);
  });

  test('extend predicate', () {
    expect(html.queryXPath('//tr/td[@class="first1"]').nodes,
        html.queryAll('td[class="first1"]'));
    expect(html.queryXPath('//tr/td[@class^="fir"]').nodes,
        html.queryAll('td[class^="fir"]'));
    expect(html.queryXPath('//tr/td[@class~="form"]').nodes,
        html.queryAll('td[class~="form"]'));
    expect(html.queryXPath(r'//tr/td[@class$="1"]').nodes,
        html.queryAll(r'td[class$="1"]'));
  });

  test('combination query', () {
    expect(html.queryXPath('//div/a|//div[@class="head"]').nodes,
        [html.query('a'), html.query('.head')]);
    expect(html.queryXPath('//div/a | //div[@class="head"]').nodes,
        [html.query('a'), html.query('.head')]);
  });

  test('axes', () {
    expect(html.queryXPath('//td[@id="td1"]/attribute::class').attr,
        html.query('#td1')!.attributes['class']);
    expect(html.queryXPath('//td[@id="td1"]/attribute::*').attrs,
        html.query('#td1')!.attributes.values);
    expect(html.queryXPath('//td/parent::*').node, html.query('tr'));
    expect(html.queryXPath('//tr/child::*').nodes, html.queryAll('td'));
    expect(
        html.queryXPath('//td/ancestor::*').nodes, ancestor(html.query('td')));
    expect(html.queryXPath('//tr/ancestor-or-self::*').nodes,
        ancestorOrSelf(html.query('tr')));
    expect(
        html.queryXPath('//table/descendant::td').nodes, html.queryAll('td'));
    expect(html.queryXPath('//table//tbody/descendant-or-self::*').nodes,
        [html.query('tbody'), html.query('tr'), ...html.queryAll('td')]);
  });

  test('function', () {
    expect(html.queryXPath('//td[contains(@class, "first")]').nodes,
        html.queryAll('td[class^="first"]'));
    expect(html.queryXPath('//td[not(contains(@class, "first"))]').nodes,
        html.queryAll('td[class^="second"]'));
    expect(html.queryXPath('//td[contains(text(), "one")]').nodes,
        html.queryAll('#td5'));
    expect(html.queryXPath('//td[starts-with(text(), "o")]').nodes,
        html.queryAll('#td5'));
    expect(html.queryXPath('//td[ends-with(text(), "e")]').nodes,
        [html.query('#td5'), html.query('#td7')]);
    expect(
        html
            .queryXPath('//td[contains(@class, "first") and text() = "3"]')
            .nodes,
        html.queryAll('#td3'));
  });

  test('multi predicate', () {
    expect(html.queryXPath('//td[@class^="second"][2]').nodes,
        html.queryAll('#td6'));
  });
}
