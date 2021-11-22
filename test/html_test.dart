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

<div class="comments">
  <div class="c1">
    <div class="c2">
      <div class="username">uploader</div>
      <div class="context">Hello, I'm uploader</div>
    </div>
  </div>
  <div class="c1">
    <div class="c2">
      <div class="username">user1</div>
      <div class="source test">+4</div>
      <div class="context">nice work!</div>
    </div>
  </div>
  <div class="c1">
    <div class="c2">
      <div class="username">user2</div>
      <div class="source test">+4</div>
      <div class="context">I like it!</div>
    </div>
  </div>
</div>

</body>
</html>
''';

final html = parse(htmlString).documentElement!;

extension TestTransfer on Element {
  XPathNode? query(String selector) =>
      HtmlNodeTree.buildNullNode(querySelector(selector));

  List<XPathNode> queryAll(String selector) =>
      querySelectorAll(selector).map((e) => HtmlNodeTree.buildNode(e)).toList();
}

void main() {
  test('basic', () {
    expect(html.queryXPath('//div/a').element, html.query('a'));
    expect(html.queryXPath('//div/a/@href').attr,
        html.query('a')!.attributes['href']);
    expect(html.queryXPath('//td[@id="td1"]/@*').attrs,
        html.query('#td1')!.attributes.values);
    expect(html.queryXPath('//div/a/text()').attr, html.query('a')!.text);
    expect(html.queryXPath('//tr/node()').elements,
        html.query('tr')!.childrenNode);
  });

  test('simple predicate', () {
    expect(html.queryXPath('//tr/td[1]').element, html.query('#td1'));
    expect(html.queryXPath('//tr/td[last()]').element, html.query('#td8'));
    expect(html.queryXPath('//tr/td[last()-1]').element, html.query('#td7'));
    expect(html.queryXPath('//tr/td[position()<3]').elements,
        [html.query('#td1'), html.query('#td2')]);
    expect(html.queryXPath('//tr/td[position() < 3]').elements,
        [html.query('#td1'), html.query('#td2')]);
  });

  test('complex predicate', () {
    expect(
        html
            .queryXPath('//tr/td[position() >= 2 and @class="second1"]')
            .elements,
        [html.query('#td5'), html.query('#td6')]);
    expect(
        html.queryXPath('//tr/td[position() >= 2 and position() < 4]').elements,
        [html.query('#td2'), html.query('#td3')]);
    expect(
        html.queryXPath('//tr/td[position() <= 1 or position() >= 8]').elements,
        [html.query('#td1'), html.query('#td8')]);
  });

  test('extend predicate', () {
    expect(html.queryXPath('//tr/td[@class="first1"]').elements,
        html.queryAll('td[class="first1"]'));
    expect(html.queryXPath('//tr/td[@class^="fir"]').elements,
        html.queryAll('td[class^="fir"]'));
    expect(html.queryXPath('//tr/td[@class~="form"]').elements,
        html.queryAll('td[class~="form"]'));
    expect(html.queryXPath(r'//tr/td[@class$="1"]').elements,
        html.queryAll(r'td[class$="1"]'));
  });

  test('combination query', () {
    expect(html.queryXPath('//div/a|//div[@class="head"]').elements,
        [html.query('a'), html.query('.head')]);
    expect(html.queryXPath('//div/a | //div[@class="head"]').elements,
        [html.query('a'), html.query('.head')]);
  });

  test('axes', () {
    expect(html.queryXPath('//td[@id="td1"]/attribute::class').attr,
        html.query('#td1')!.attributes['class']);
    expect(html.queryXPath('//td[@id="td1"]/attribute::*').attrs,
        html.query('#td1')!.attributes.values);
    expect(html.queryXPath('//td/parent::*').element, html.query('tr'));
    expect(html.queryXPath('//tr/child::*').elements, html.queryAll('td'));
    expect(html.queryXPath('//td/ancestor::*').elements,
        ancestor(html.query('td')));
    expect(html.queryXPath('//tr/ancestor-or-self::*').elements,
        ancestorOrSelf(html.query('tr')));
    expect(html.queryXPath('//table/descendant::td').elements,
        html.queryAll('td'));
    expect(html.queryXPath('//table//tbody/descendant-or-self::*').elements,
        [html.query('tbody'), html.query('tr'), ...html.queryAll('td')]);
  });

  test('function', () {
    expect(html.queryXPath('//td[contains(@class, "first")]').elements,
        html.queryAll('td[class^="first"]'));
    expect(html.queryXPath('//td[not(contains(@class, "first"))]').elements,
        html.queryAll('td[class^="second"]'));
    expect(html.queryXPath('//td[contains(text(), "one")]').elements,
        html.queryAll('#td5'));
    expect(html.queryXPath('//td[starts-with(text(), "o")]').elements,
        html.queryAll('#td5'));
    expect(html.queryXPath('//td[ends-with(text(), "e")]').elements,
        [html.query('#td5'), html.query('#td7')]);
    expect(
        html
            .queryXPath('//td[contains(@class, "first") and text() = "3"]')
            .elements,
        html.queryAll('#td3'));
  });
}
