# xpath_selector

[![Pub](https://img.shields.io/pub/v/xpath_selector.svg?style=flat-square)](https://pub.dartlang.org/packages/xpath_selector)

一款用于定位Html和Xml元素的XPath选择器

[English](https://github.com/simonkimi/xpath_selector/blob/master/README.md) | 中文文档

## 轻松使用

您有三种方法可以进行XPath查询

```dart
// 通过字符串创建
final result1 = XPath.html(html).query('//div');
final result2 = XPath.xml(html).query('//child');

// 或通过htmlh或xml包的dom创建
final result3 = XPath.htmlElement(htmlDom).query('//div');
final result4 = XPath.xmlElement(xmlRoot).query('//child');

// 或直接通过Element查询
final result5 = htmlDom.queryXPath('//div');
final result6 = xmlRoot.queryXPath('//child');


// 获取查询结果的所有节点
print(result1.elements);

// 获取查询结果的第一个节点
print(result1.element);

// 获取查询结果的所有属性
print(result1.attrs);

// 获取查询结果的第一个有效属性
print(result1.attr);
```

更多的例子可以参考 [Xml测试例](https://github.com/simonkimi/xpath_selector/blob/master/test/xml_test.dart) | [Html测试例](https://github.com/simonkimi/xpath_selector/blob/master/test/html_test.dart)


## 扩展语法

在属性选择器中, 本解析器以css风格扩展了如下属性选择器

|表达式|css|描述|
|---|---|---|
|[@attr='value']|[attr="value"]|选择带有 attr="value" 属性的所有元素。|
|[@attr~='value']|[attr~="value"]|选择 attr 属性包含单词 "value" 的所有元素。|
|[@attr^='value']|[attr^="value"]|选择其 attr 属性值以 "value" 开头的元素。|
|[@attr$='value']|[attr$="value"]|选择其 attr 属性值以 "value" 结尾的元素。|
|[@attr*='value']|[attr*="value"]|选择其 attr 属性值中包含 "value" 子串的元素。|