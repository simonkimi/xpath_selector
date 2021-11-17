final nodeTestWithPredicate = RegExp(r'(?<node>.+)\[(?<predicate>.+)\]');
final predicateLast = RegExp(r'last\(\s*\)');
final predicatePosition = RegExp(r'position\(\s*\)');
final predicateInt = RegExp(r'^(?<num>\d+)$');
final predicateMultiple = RegExp(r'[\+\-\*\/]');
final simplePosition = RegExp(r'position\(\s*\)\s*(?<op><|<=|>|>=)\s*(?<num>\d+)');
final simpleLast = RegExp(r'last\(\s*\)\s*(?<op>\+|\-|\*|\/%\^)\s*(?<num>\d+)');