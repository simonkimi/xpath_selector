# xpath_selector_xml_parser

English | [简体中文](https://github.com/simonkimi/xpath_selector/tree/master/xpath_selector_xml_parser)

## Usage

There are three ways to create xpath queries: 

1. Use the `queryXPath` method directly on the html `Node`
2. Use `XmlXpath.node ([XmlNode])` to create a query and then use the `query` method to perform the query
3. Use `XmlXpath.html ([XmlString])` to parse the xml, and then use `query` to query

## Example

```dart
import 'package:xml/xml.dart';
import 'package:xpath_selector_xml_parser/xpath_selector_xml_parser.dart';

final input = '''
<bookstore xmlns:h="https://test.z31.ink" xmlns:t="https://test.z31.ink/sub">
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

void main() {
  final xml1 = XmlDocument.parse(input);
  final xml2 = XmlXPath.node(xml1);
  final xml3 = XmlXPath.xml(input);

  print(xml1.queryXPath('//book'));
  print(xml2.query('//book/title'));
  print(xml3.query('//*[@lang="en"]'));
}

```
