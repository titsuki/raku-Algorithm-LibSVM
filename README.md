[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-LibSVM.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-LibSVM)

NAME
====

Algorithm::LibSVM - A Perl 6 bindings for libsvm

SYNOPSIS
========

EXAMPLE 1
---------

    use Algorithm::LibSVM;
    use Algorithm::LibSVM::Parameter;
    use Algorithm::LibSVM::Problem;
    use Algorithm::LibSVM::Model;

    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => RBF);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem('heart_scale');
    my @r = $libsvm.cross-validation($problem, $param, 10);
    $libsvm.evaluate($problem.y, @r).say; # {acc => 81.1111111111111, mse => 0.755555555555556, scc => 1.01157627463546}

EXAMPLE 2
---------

    use Algorithm::LibSVM;
    use Algorithm::LibSVM::Parameter;
    use Algorithm::LibSVM::Problem;
    use Algorithm::LibSVM::Model;

    sub gen-train {
        my $max-x = 1;
        my $min-x = -1;
        my $max-y = 1;
        my $min-y = -1;

        do for ^300 {
           my $x = $min-x + rand * ($max-x - $min-x);
           my $y = $min-y + rand * ($max-y - $min-y);

           my $label = do given $x, $y {
              when ($x - 0.5) ** 2 + ($y - 0.5) ** 2 <= 0.2 {
                     1
              }
              when ($x - -0.5) ** 2 + ($y - -0.5) ** 2 <= 0.2 {
                  2
              }
              default { Nil }
        }
        ($label,"1:$x","2:$y") if $label.defined;
      }.sort({ $^a.[0] cmp $^b.[0] })>>.join(" ")
    }

    my Str @train = gen-train;

    my Pair @test = (q:to/END/).split(" ", 2)[1].split(" ")>>.split(":").map: { .[0].Int => .[1].Num };
    1 1:0.5 2:0.5
    END

    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => LINEAR);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    my $model = $libsvm.train($problem, $parameter);
    say $model.predict(features => @test)<label> # 1

DESCRIPTION
===========

Algorithm::LibSVM is a Perl 6 bindings for libsvm.

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.
