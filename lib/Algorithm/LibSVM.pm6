use v6;
use NativeCall;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Model;
use NativeHelpers::Array;

unit class Algorithm::LibSVM;

my constant $library = %?RESOURCES<libraries/svm>.Str;

my sub svm_cross_validation(Algorithm::LibSVM::Problem, Algorithm::LibSVM::Parameter, int32, CArray[num64]) is native($library) { * }
my sub svm_train(Algorithm::LibSVM::Problem, Algorithm::LibSVM::Parameter) returns Algorithm::LibSVM::Model is native($library) { * }
my sub svm_check_parameter(Algorithm::LibSVM::Problem, Algorithm::LibSVM::Parameter) returns Str is native($library) { * }
my sub svm_check_probability_model(Algorithm::LibSVM::Model) returns int32 is native($library) { * }

my sub print_string_stdout(Str) returns Pointer[void] is native($library) { * }
my sub svm_set_print_string_function(&print_func (Str --> Pointer[void])) is native($library) { * }

submethod BUILD(Bool :$verbose? = False) {
    unless $verbose {
        my $f = sub (Str --> Pointer[void]) { Nil };
        svm_set_print_string_function($f);
    }
}

method cross-validation(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param, Int $nr-fold) returns Array {
    my $target = CArray[num64].new;
    $target[$problem.l] = 0e0; # memory allocation
    svm_cross_validation($problem, $param, $nr-fold, $target);
    copy-to-array($target, $problem.l);
}

method check-parameter(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param) returns Bool {
    my $msg = svm_check_parameter($problem, $param);
    return False if $msg.defined;
    True
}

method check-probability-model(Algorithm::LibSVM::Model $model) returns Bool {
    Bool(svm_check_probability_model($model))
}

method train(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param) returns Algorithm::LibSVM::Model {
    svm_train($problem, $param)
}

multi method load-problem(\lines) returns Algorithm::LibSVM::Problem {
    self!_load-problem(lines)
}

multi method load-problem(Str $filename) returns Algorithm::LibSVM::Problem {
    self!_load-problem($filename.IO.lines)
}

method !_load-problem(\lines) {
    my $prob-y = CArray[num64].new;
    my $prob-x = CArray[Algorithm::LibSVM::Node].new;
    
    my $y-idx = 0;
    for lines -> $line {
        my ($label, $features) = $line.trim.split(/\s+/,2);
        my @feature-list = $features.split(/\s+/);

        my $num-of-x-space = @feature-list.elems;
        my $next = Algorithm::LibSVM::Node.new(index => -1, value => 0e0);
        for @feature-list>>.split(":", :skip-empty).sort({ $^b[0] <=> $^a[0] }) -> ($index, $value) {
            $next = Algorithm::LibSVM::Node.new(index => $index.Int, value => $value.Num, next => $next);
        }
        $prob-y[$y-idx] = $label.Num;
        $prob-x[$y-idx] = $next;
        $y-idx++;
    }
    return Algorithm::LibSVM::Problem.new(l => $y-idx, y => $prob-y, x => $prob-x);
}

my sub svm_load_model(Str) returns Algorithm::LibSVM::Model is native($library) { * }

method load-model(Str $filename) returns Algorithm::LibSVM::Model {
    svm_load_model($filename)
}

method evaluate(@true-values, @predicted-values) {
    if @true-values.elems != @predicted-values.elems {
        die 'ERROR: @true-values.elem != @predicted-values.elem';
    }
    my ($total-correct, $total-error) = 0, 0;
    my ($sum-p, $sum-t, $sum-pp, $sum-tt, $sum-pt) = 0, 0, 0, 0, 0;
    for @true-values Z @predicted-values -> ($t, $p) {
        $total-correct++ if $p == $t;
        $total-error += ($p - $t) ** 2;
        $sum-p += $p;
        $sum-t += $t;
        $sum-pp += $p ** 2;
        $sum-tt += $t ** 2;
        $sum-pt += $p * $t;
    }

    my Num $num-t = @true-values.elems.Num;
    my Num $accuracy = 100.0 * $total-correct / $num-t;
    my Num $mean-squared-error = $total-error / $num-t;

    my Num $denom =  ($num-t * $sum-pt - $sum-p ** 2) * ($num-t * $sum-pt - $sum-t ** 2);
    my Num $squared-correlation-coefficient
    = do if -1e-20 <= $denom <= 1e-20 {
        Num;
    } else {
        ($num-t * $sum-pt - $sum-p * $sum-t) ** 2 / $denom;
    }
    { acc => $accuracy, mse =>  $mean-squared-error, scc =>  $squared-correlation-coefficient }
}

=begin pod

=head1 NAME

Algorithm::LibSVM - A Perl 6 bindings for libsvm

=head1 SYNOPSIS

  use Algorithm::LibSVM;

=head1 DESCRIPTION

Algorithm::LibSVM is a Perl 6 bindings for libsvm.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the MIT.

=end pod
