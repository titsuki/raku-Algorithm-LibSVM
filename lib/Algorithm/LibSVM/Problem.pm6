use v6;
use NativeCall;
use Algorithm::LibSVM::Node;

unit class Algorithm::LibSVM::Problem is export is repr('CStruct');

has int32 $.l;
has CArray[num64] $.y;
has CArray[Algorithm::LibSVM::Node] $.x;

method BUILD(int32 :$l, CArray[num64] :$y, CArray[Algorithm::LibSVM::Node] :$x) {
    $!l = $l;
    $!y := $y;
    $!x := $x;
}

=begin pod

=head1 NAME

Algorithm::LibSVM::Problem - A Perl 6 Algorithm::LibSVM::Problem class

=head1 SYNOPSIS

  use Algorithm::LibSVM::Problem;

=head1 DESCRIPTION

Algorithm::LibSVM::Problem is a Perl 6 Algorithm::LibSVM::Problem class

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
