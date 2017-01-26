use v6;
unit grammar Algorithm::LibSVM::Grammar;

token TOP { <bodylist> }
token number { '-'* \d+ [ \. \d+ ]? }
token decimal { \d+ }
rule bodylist { [ <body> | [ <body> \n+ ] ]+ }
rule body { <number> <ws> <pairlist> }
rule pairlist { [ <pair> | [ <pair> <ws> ] ]+ }
rule pair { <key=.decimal> ':' <value=.number> }
