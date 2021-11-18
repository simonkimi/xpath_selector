# xpath_selector

[![Pub](https://img.shields.io/pub/v/xpath_selector.svg?style=flat-square)](https://pub.dartlang.org/packages/xpath_selector)

An XPath selector for locating Html and Xml elements

English | [中文文档](https://github.com/simonkimi/xpath_selector/blob/master/README-zh_CN.MD)

## Easy to use

You have three ways to do XPath queries

```dart
final html = '''<html><div></div></html>''';
final htmlDom = parse(htmlString).documentElement!;
final xml = '''<root><child></child></root>''';
final xmlRoot = XmlDocument.parse().rootElement;

// Create by html string
final result1 = XPath.html(html).query('//div');
final result2 = XPath.xml(html).query('//child');

// Or through the dom of the HTML or Xml package
final result3 = XPath.htmlElement(htmlDom).query('//div');
final result4 = XPath.xmlElement(xmlRoot).query('//child');

// Or query directly through element
final result5 = htmlDom.queryXPath('//div');
final result6 = xmlRoot.queryXPath('//child');

// Get all nodes of query results
print(result1.elements);

// Get the first node of query results

print(result1.element);

// Get all properties of query results
print(result1.attrs);

// Get the first valid property of the query result (not null)
print(result1.attr);
```

More examples can be referred to [Xml](https://github.com/simonkimi/xpath_selector/blob/master/test/xml_test.dart) | [Html](https://github.com/simonkimi/xpath_selector/blob/master/test/html_test.dart)


## Extended syntax

In the attribute selector, the parser extends the following attribute selector in CSS style


|Expression|Css|Description|
|---|---|---|
|[@attr='value']|[attr="value"]|Selects all elements with attr="value"|
|[@attr~='value']|[attr~="value"]|Selects all elements attribute containing the word "value"|
|[@attr^='value']|[attr^="value"]|Selects all elements whose attr attribute value begins with "value"|
|[@attr$='value']|[attr$="value"]|Selects all elements whose attr attribute value ends with "value"|
|[@attr*='value']|[attr*="value"]|Selects all elements whose attr attribute value contains the substring "value"|