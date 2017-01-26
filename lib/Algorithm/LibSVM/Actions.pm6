use v6;
unit class Algorithm::LibSVM::Actions;

method TOP($/) { make $<bodylist>.made }
method bodylist($/) { make $<body>>>.made }
method body($/) { make { top => $<number>.Num, pairs => $<pairlist>.made } }
method pairlist($/) { make $<pair>>>.made }
method pair($/) { make $<key>.Int => $<value>.Num }
