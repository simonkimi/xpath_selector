import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xpath_selector/xpath_selector.dart';

final input = '''
<bookstore>
    <book category="children">
        <title lang="en">Harry Potter</title>
        <author>J K. Rowling</author>
        <year>2005</year>
        <price>29.99</price>
    </book>
    <book category="cooking">
        <title lang="en">Everyday Italian</title>
        <author>Giada De Laurentiis</author>
        <year>2005</year>
        <price>30.00</price>
    </book>
    <book category="web" cover="paperback">
        <title lang="en">Learning XML</title>
        <author>Erik T. Ray</author>
        <year>2003</year>
        <price>39.95</price>
    </book>
    <book category="web">
        <title lang="en">XQuery Kick Start</title>
        <author>James McGovern</author>
        <author>Per Bothner</author>
        <author>Kurt Cagle</author>
        <author>James Linn</author>
        <author>Vaidyanathan Nagarajan</author>
        <year>2003</year>
        <price>49.99</price>
    </book>
</bookstore>
''';

final xml = XmlDocument.parse(input).rootElement;

extension XmlTransfer on XmlElement {
  XPathNode? query(String selector) {
    final result = findAllElements(selector).toList();
    if (result.isEmpty) return null;
    return XmlNodeTree.buildNode(result.first);
  }

  List<XPathNode> queryAll(String selector,
      [bool Function(XmlNode element)? filter]) {
    var result = findAllElements(selector);
    if (filter != null) result = result.where(filter);
    return result.map((e) => XmlNodeTree.buildNode(e)).toList();
  }
}

void main() {
  test('basic', () {
    expect(xml.queryXPath('//book').elements, xml.queryAll('book'));
    expect(xml.queryXPath('//book/title').elements, xml.queryAll('title'));
    expect(xml.queryXPath('//*[@lang="en"]').elements, xml.queryAll('title'));
    expect(
        xml.queryXPath('//title[@lang="en"]').elements, xml.queryAll('title'));
  });

  test('index', () {
    expect(xml.queryXPath('//book[1]').element, xml.queryAll('book')[0]);
    expect(xml.queryXPath('//book[last()]').element, xml.queryAll('book').last);
    expect(
        xml.queryXPath('//book[last() - 1]').element, xml.queryAll('book')[2]);
  });

  test('attr', () {
    expect(xml.queryXPath('//title/@lang').attrs, List.filled(4, 'en'));
    expect(xml.queryXPath('//title/text()').attrs,
        xml.queryAll('title').map((e) => e.text));
    expect(xml.queryXPath('//book[1]/node()').elements,
        xml.queryAll('book')[0].childrenNode);
  });

  test('combination query', () {
    expect(xml.queryXPath('//title|//book').attrs,
        [...xml.queryAll('title'), ...xml.queryAll('book')]);
    expect(xml.queryXPath('//title | //book').attrs,
        [...xml.queryAll('title'), ...xml.queryAll('book')]);
  });
}
