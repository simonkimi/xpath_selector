# xpath_for_html
[![Pub](https://img.shields.io/pub/v/xpath_for_html.svg?style=flat-square)](https://pub.dartlang.org/packages/xpath_for_html)

一款用于定位Html元素的XPath选择器

### 轻松使用

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

更多的例子可以参考[](展示例)或[](测试例)
