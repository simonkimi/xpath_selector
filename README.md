# xpath_for_html

[![Pub](https://img.shields.io/pub/v/xpath_for_html.svg?style=flat-square)](https://pub.dartlang.org/packages/xpath_for_html)

An XPath selector for locating HTML elements

## Easy to use

You have three ways to do XPath queries

```dart

final html = '''<html><div></div></html>''';
final htmlDom = parse(htmlString).documentElement!;

// Create by html string

final result1 = XPath.html(html).query('//div');

// Or through the dom of the HTML package
final result2 = XPath(htmlDom).query('//div');

// Or query directly through element
final result3 = htmlDom.queryXPath('//div');

// Get all nodes of query results
print(result1.elements);

// Get the first node of query results

print(result1.element);

// Get all properties of query results
print(result1.attrs);

// Get the first valid property of the query result (not null)
print(result1.attr);
```

More examples can be referred to[example](https://github.com/simonkimi/xpath_for_html/blob/master/example/example.dart)
or [test](https://github.com/simonkimi/xpath_for_html/blob/master/test/test.dart)

## Basic syntax

|Expression|Css or html|Description|Attr|
|---|---|---|---|
|//|Selects nodes in the document from the current node that match the selection no matter where they are|
|/|Selects from the root node||
|..|Selects the parent of the current node| |
|tag[n]|nth-child(n)|Select by index|
|tag[@key="value"]|tag[key="value"]|Filter properties|
|node()|.children|child|
|text()|.text|text|√|
|@attr| |Selects attributes|√|

For more syntax, please refer to[XPath](https://www.w3school.com/xpath/xpath_syntax.asp)

## Extended syntax


In the attribute selector, the parser extends the following attribute selector in CSS style


|Expression|Css|Description|
|---|---|---|
|[@attr='value']|[attr="value"]|Selects all elements with attr="value"|
|[@attr~='value']|[attr~="value"]|Selects all elements attribute containing the word "value"|
|[@attr^='value']|[attr^="value"]|Selects all elements whose attr attribute value begins with "value"|
|[@attr$='value']|[attr$="value"]|Selects all elements whose attr attribute value ends with "value"|
|[@attr*='value']|[attr*="value"]|Selects all elements whose attr attribute value contains the substring "value"|