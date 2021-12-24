## 1.0.0

- Initial version.

## 1.0.1

- Add XPathElement selector

## 1.0.2

- Fix `/.[@attr=value]` parse error

## 1.0.3

- Support `not(function(param1, param2))`

## 1.0.4

- Fix `child=value`

## 1.1.0

- Support `not(funcion()|attr = """)`
- Support namespace function: `local-name()` `name()`

## 2.0.0

1. Custom parser
2. Remove class`XPathElement`, which merge to`XPathNode`
3. In `XPathResult`, `elements`=>`nodes`, `elements`=>`element`

## 2.0.1

- Support more leftValue on `not(function(leftValue, param2))`

## 2.1.0

- Add query to node

## 2.2.0

- Support multi predicate, now you can use `//tag[predicate][predicate2][predicate3]`