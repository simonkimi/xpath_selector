final nodeTestWithPredicate = RegExp(r'(?<node>.+)\[(?<predicate>.+)\]');
final predicateLast = RegExp(r'last\(\s*\)');
final predicatePosition = RegExp(r'position\(\s*\)');
final predicateInt = RegExp(r'^(?<num>\d+)$');
final predicateChild =
    RegExp(r'(?<child>\w+)\s*(?<op><|<=|>|>=)\s*(?<num>\d+)');
final predicateSym = RegExp(r'\+|\-|\*|\/|\smod\s|\sdiv\s|%');

final simplePosition =
    RegExp(r'position\(\s*\)\s*(?<op><|<=|>|>=)\s*(?<num>\d+)');
final simpleLast = RegExp(r'last\(\s*\)\s*(?<op>\+|\-|\*|\/%\^)\s*(?<num>\d+)');
final simpleSingleLast = RegExp(r'last\(\s*\)');

final predicateAttr = RegExp(
    r'''@(?<attr>\w+)(?<op>=|~=|\|=|\^=|\$=|\*=|!=)['"](?<value>.+)['"]''');
final functionNodeTest = RegExp(r'^(?<function>\w+)\(\s*\)$');
