[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-LibSVM.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-LibSVM)

NAME
====

Algorithm::LibSVM - A Perl 6 bindings for libsvm

SYNOPSIS
========

    use Algorithm::LibSVM;

    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => LINEAR);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    $libsvm.check-parameter($problem, $parameter);
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
