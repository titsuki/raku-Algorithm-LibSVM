use v6;
use NativeCall;
use Algorithm::LibSVM::Node;
use Algorithm::LibSVM::Actions;
use Algorithm::LibSVM::Grammar;

my class Algorithm::LibSVM::CProblem:auth<zef:titsuki>:ver<0.0.14> is export is repr('CStruct') {
    has int32 $.l;
    has CArray[num64] $!y;
    has CArray[Algorithm::LibSVM::Node] $!x;

    method BUILD(int32 :$l, CArray[num64] :$y, CArray[Algorithm::LibSVM::Node] :$x) {
        $!l = $l;
        $!y := $y;
        $!x := $x;
    }

    method y(--> List) {
        my @ret;
        @ret[$_] = $!y[$_] for ^$!l;
        @ret
    }

    method x(--> List) {
        my @ret;
        @ret[$_] = $!x[$_] for ^$!l;
        @ret
    }
}

my class Algorithm::LibSVM::Problem:auth<zef:titsuki>:ver<0.0.14> is export {
    has Algorithm::LibSVM::CProblem $.as-c;
    has Int $.nr-feature;
    method BUILD(int32 :$l, CArray[num64] :$y, CArray[Algorithm::LibSVM::Node] :$x, :$!nr-feature) {
        $!as-c := Algorithm::LibSVM::CProblem.new(:$l, :$y, :$x);
    }
    method l(--> Int) { $!as-c.l }
    method x(--> List) { $!as-c.x }
    method y(--> List) { $!as-c.y }

    multi method _load-problem(::?CLASS:U: \lines --> Algorithm::LibSVM::Problem) {
        self!_load-problem(lines)
    }

    multi method _load-problem(::?CLASS:U: Str $filename --> Algorithm::LibSVM::Problem) {
        self!_load-problem($filename.IO.lines)
    }

    method from-file(::?CLASS:U: Str $filename --> Algorithm::LibSVM::Problem) {
        self!_load-problem($filename.IO.lines)
    }

    multi method from-matrix(::?CLASS:U: @x, @y --> Algorithm::LibSVM::Problem) {
        my @shaped-x[+@x;@x[0].elems] = @x.clone;
        ::?CLASS.from-matrix(@shaped-x, @y)
    }

    multi method from-matrix(::?CLASS:U: @x where { $_.shape ~~ ($,$) }, @y --> Algorithm::LibSVM::Problem) is default {
        my ($nr, $nc) = @x.shape;
        my $nr-feature = 0;
        my $prob-y = CArray[num64].new;
        my $prob-x = CArray[Algorithm::LibSVM::Node].new;
        my $y-idx = 0;
        for ^@y -> $row {
            my $next = Algorithm::LibSVM::Node.new(index => -1, value => 0e0);
            for (1..$nc).reverse -> $index {
                next unless @x[$row;$index-1].defined;
                $nr-feature = ($nr-feature, $index.Int).max;
                $next = Algorithm::LibSVM::Node.new(index => $index, value => @x[$row;$index-1].Num, next => $next);
            }
            $prob-y[$y-idx] = @y[$y-idx].Num;
            $prob-x[$y-idx] = $next;
            $y-idx++;
        }
        Algorithm::LibSVM::Problem.new(l => $y-idx, y => $prob-y, x => $prob-x, :$nr-feature);
    }

    multi method from-kernel-matrix(::?CLASS:U: @x, @y --> Algorithm::LibSVM::Problem) {
        my @shaped-x[+@x;@x[0].elems] = @x.clone;
        ::?CLASS.from-matrix(@shaped-x, @y)
    }

    multi method from-kernel-matrix(::?CLASS:U: @x where { $_.shape ~~ ($,$) }, @y --> Algorithm::LibSVM::Problem) is default {
        my ($nr, $nc) = @x.shape;
        my $nr-feature = 0;
        my $prob-y = CArray[num64].new;
        my $prob-x = CArray[Algorithm::LibSVM::Node].new;
        my $y-idx = 0;
        for ^$nr -> $i {
            my $next = Algorithm::LibSVM::Node.new(index => -1, value => 0e0);
            for @(^$nc).reverse -> $j {
                next unless @x[$i;$j].defined;
                $nr-feature = ($nr-feature, $j.Int + 1).max;
                $next = Algorithm::LibSVM::Node.new(index => $j + 1, value => @x[$i;$j].Num, next => $next);
            }
            $next = Algorithm::LibSVM::Node.new(index => 0, value => ($i + 1).Num, next => $next);
            $prob-y[$y-idx] = @y[$y-idx].Num;
            $prob-x[$y-idx] = $next;
            $y-idx++;
        }
        Algorithm::LibSVM::Problem.new(l => $y-idx, y => $prob-y, x => $prob-x, :$nr-feature);
    }

    method !_load-problem(\lines) {
        my $nr-feature = 0;
        my $prob-y = CArray[num64].new;
        my $prob-x = CArray[Algorithm::LibSVM::Node].new;
        my $y-idx = 0;
        for lines -> $line {
            my $parsed = Algorithm::LibSVM::Grammar.parse($line, actions => Algorithm::LibSVM::Actions).made;
            my ($label, $feature) = $parsed.head<label>, $parsed.head<pairs>;

            my $next = Algorithm::LibSVM::Node.new(index => -1, value => 0e0);
            for @($feature).sort(-*.key).map({ .key, .value }) -> ($index, $value) {
                $nr-feature = ($nr-feature, $index.Int).max;
                $next = Algorithm::LibSVM::Node.new(index => $index.Int, value => $value.Num, next => $next);
            }
            $prob-y[$y-idx] = $label.Num;
            $prob-x[$y-idx] = $next;
            $y-idx++;
        }
        return Algorithm::LibSVM::Problem.new(l => $y-idx, y => $prob-y, x => $prob-x, :$nr-feature);
    }
}

=begin pod

=head1 NAME

Algorithm::LibSVM::Problem - A Raku Algorithm::LibSVM::Problem class

=head1 SYNOPSIS

  use Algorithm::LibSVM::Problem;

=head1 DESCRIPTION

Algorithm::LibSVM::Problem is a Raku Algorithm::LibSVM::Problem class

=head2 METHODS

=head3 l

Defined as:

        method l return(--> Int:D)

Returns the number of the training data.

=head3 y

Defined as:

        method y(--> List)

Returns the array containing the target values (C<Int> values in classification, C<Num> values in regression) of the training data.

=head3 x

Defined as:

        method x(--> List)

Returns the array of pointers, each of which points to a sparse representation (i.e. array of C<Algorithm::LibSVM::Node>) of one training vector.

=head3 nr-feature

Defined as:

        method nr-feature(--> Int)

Returns the number of features.

=head3 from-matrix

Defined as:

        method from-matrix(::?CLASS:U: @x where { $_.shape ~~ ($,$) }, @y --> Algorithm::LibSVM::Problem)

Creates a C<Algorithm::LibSVM::Problem> instance. Where C<@x> is the 2-dimensional shaped matrix for features, C<@y> is the 1-dimensional array for labels.

=head3 from-kernel-matrix

Defined as:

        method from-kernel-matrix(::?CLASS:U: @x where { $_.shape ~~ ($,$) }, @y --> Algorithm::LibSVM::Problem)

Creates a C<Algorithm::LibSVM::Problem> instance. Where C<@x> is the 2-dimensional shaped kernel matrix, C<@y> is the 1-dimensional array for labels.

=head3 from-file

Defined as:

        method from-file(::?CLASS:U: Str $filename --> Algorithm::LibSVM::Problem)

Creates a C<Algorithm::LibSVM::Problem> instance. Where <$filename> is the filename of the libsvm format file.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
