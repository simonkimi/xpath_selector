# xpath_for_html

[![Pub](https://img.shields.io/pub/v/xpath_for_html.svg?style=flat-square)](https://pub.dartlang.org/packages/xpath_for_html)

一款用于定位Html元素的XPath选择器

## 轻松使用

您有三种方法可以进行XPath查询

```dart

final html = '''<html><div></div></html>''';
final htmlDom = parse(htmlString).documentElement!;

// 通过字符串创建
final result1 = XPath.html(html).query('//div');

// 或通过html包的dom创建
final result2 = XPath(htmlDom).query('//div');

// 或直接通过Element查询
final result3 = htmlDom.queryXPath('//div');
```

更多的例子可以参考[展示例](https://github.com/simonkimi/xpath_for_html/blob/master/example/example.dart)
或 [测试例](https://github.com/simonkimi/xpath_for_html/blob/master/test/test.dart)

## 基础语法

|表达式|css或html|描述|存在attr|
|---|---|---|---|
|//|从匹配选择的当前节点选择文档中的节点，而不考虑它们的位置。|
|/|从根节点选取||
|..|选取当前节点的父节点| |
|tag[n]|nth-child(n)|按位置选择|
|tag[@key="value"]|tag[key="value"]|选择属性|
|node()|.children|子节点|
|text()|.text|内容|√|
|@attr| |选取属性|√|

更多语法请参照[XPath语法](https://www.w3school.com.cn/xpath/xpath_syntax.asp)

## 扩展语法

在属性选择器中, 本解析器以css风格扩展了如下属性选择器

|表达式|css|描述|
|---|---|---|
|[@attr='value']|[attr="value"]|选择带有 attr="value" 属性的所有元素。|
|[@attr~='value']|[attr~="value"]|选择 attr 属性包含单词 "value" 的所有元素。|
|[@attr^='value']|[attr^="value"]|选择其 attr 属性值以 "value" 开头的元素。|
|[@attr$='value']|[attr$="value"]|选择其 attr 属性值以 "value" 结尾的元素。|
|[@attr*='value']|[attr*="value"]|选择其 attr 属性值中包含 "value" 子串的元素。|


## 暂不支持语法
以下语法因为种种原因暂不支持, 如需要请提issue

|名称|说明|
|---|---|
|attribute::*|选取当前节点的所有属性。|