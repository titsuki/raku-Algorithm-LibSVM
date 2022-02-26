use v6;
unit grammar Algorithm::LibSVM::Grammar:ver<0.0.15>;

token TOP { <bodylist> }
token number { ['-'|'+']* \d+ [ \. \d+ [ 'e' '-'? \d+ ]? ]? }
token integer { \d+ }
token comment { '#' <-[\:] -[\n]>+ }
rule bodylist { [ <body> \n? ]+ }
rule body { <number> <ws> <pairlist> <ws>? <comment>? }
rule pairlist { <pair>+ %% <ws> }
rule pair { <key=.integer> ':' <value=.number> }

=begin pod

=head1 NAME

Algorithm::LibSVM::Grammar - A Raku Algorithm::LibSVM::Grammar class

=head1 SYNOPSIS

  use Algorithm::LibSVM::Grammar;

=head1 DESCRIPTION

Algorithm::LibSVM::Grammar is a Raku Algorithm::LibSVM::Grammar class

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
