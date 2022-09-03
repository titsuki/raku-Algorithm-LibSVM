use v6;
use NativeCall;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Model;
use Algorithm::LibSVM::Grammar;
use Algorithm::LibSVM::Actions;

unit class Algorithm::LibSVM:auth<zef:titsuki>:ver<0.0.17>;

my constant $library = %?RESOURCES<libraries/svm>.Str;

my sub svm_cross_validation(Algorithm::LibSVM::CProblem, Algorithm::LibSVM::Parameter, int32, CArray[num64]) is native($library) { * }
my sub svm_train(Algorithm::LibSVM::CProblem, Algorithm::LibSVM::Parameter --> Algorithm::LibSVM::Model) is native($library) { * }
my sub svm_check_parameter(Algorithm::LibSVM::CProblem, Algorithm::LibSVM::Parameter --> Str) is native($library) { * }
my sub print_string_stdout(Str --> Pointer[void]) is native($library) { * }
my sub svm_set_print_string_function(&print_func (Str --> Pointer[void])) is native($library) { * }
my sub svm_set_srand(int32) is native($library) { * }

submethod BUILD(Bool :$verbose? = False, Int :$seed = 1) {
    unless $verbose {
        my $f = sub (Str --> Pointer[void]) { Nil };
        svm_set_print_string_function($f);
    }
    svm_set_srand($seed);
}

method cross-validation(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param, Int $nr-fold --> List) {
    if $param.gamma == 0 && $problem.nr-feature > 0 {
        $param.gamma((1.0 / $problem.nr-feature).Num);
    }
    my $target = CArray[num64].allocate: $problem.l;
    svm_cross_validation($problem.as-c, $param, $nr-fold, $target);
    $target.list
}

method check-parameter(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param --> Bool) {
    my $msg = svm_check_parameter($problem.as-c, $param);
    die "$msg" if $msg.defined;
    True
}

method train(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param --> Algorithm::LibSVM::Model) {
    if $param.gamma == 0 && $problem.nr-feature > 0 {
        $param.gamma((1.0 / $problem.nr-feature).Num);
    }
    svm_train($problem.as-c, $param) if self.check-parameter($problem, $param);
}

my sub svm_load_model(Str --> Algorithm::LibSVM::Model) is native($library) { * }

method load-model(Str $filename --> Algorithm::LibSVM::Model) {
    svm_load_model($filename)
}

method evaluate(@true-values, @predicted-values --> Hash) {
    if @true-values.elems != @predicted-values.elems {
        die 'ERROR: @true-values.elems != @predicted-values.elems';
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

sub parse-libsvmformat(Str $text --> List) is export {
    Algorithm::LibSVM::Grammar.parse($text, actions => Algorithm::LibSVM::Actions).made or die
}

my constant $msg = "Algorithm::LibSVM::Problem.from-file";
multi method load-problem(\lines --> Algorithm::LibSVM::Problem) is DEPRECATED($msg) {
    Algorithm::LibSVM::Problem._load-problem(lines)
}

multi method load-problem(Str $filename --> Algorithm::LibSVM::Problem) is DEPRECATED($msg) {
    Algorithm::LibSVM::Problem._load-problem($filename.IO.lines)
}

=begin pod

=head1 NAME

Algorithm::LibSVM - A Raku bindings for libsvm

=head1 SYNOPSIS

=head2 EXAMPLE 1

  use Algorithm::LibSVM;
  use Algorithm::LibSVM::Parameter;
  use Algorithm::LibSVM::Problem;
  use Algorithm::LibSVM::Model;

  my $libsvm = Algorithm::LibSVM.new;
  my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                    kernel-type => RBF);
  # heart_scale is here: https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/heart_scale
  my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-file('heart_scale');
  my @r = $libsvm.cross-validation($problem, $parameter, 10);
  $libsvm.evaluate($problem.y, @r).say; # {acc => 81.1111111111111, mse => 0.755555555555556, scc => 1.01157627463546}

=head2 EXAMPLE 2

  use Algorithm::LibSVM;
  use Algorithm::LibSVM::Parameter;
  use Algorithm::LibSVM::Problem;
  use Algorithm::LibSVM::Model;

  sub gen-train {
    my $max-x = 1;
    my $min-x = -1;
    my $max-y = 1;
    my $min-y = -1;
    my @tmp-x;
    my @tmp-y;
    do for ^300 {
        my $x = $min-x + rand * ($max-x - $min-x);
        my $y = $min-y + rand * ($max-y - $min-y);

        my $label = do given $x, $y {
            when ($x - 0.5) ** 2 + ($y - 0.5) ** 2 <= 0.2 {
                1
            }
            when ($x - -0.5) ** 2 + ($y - -0.5) ** 2 <= 0.2 {
                -1
            }
            default { Nil }
        }
        if $label.defined {
            @tmp-y.push: $label;
            @tmp-x.push: [$x, $y];
        }
    }
    # Note that @x must be a shaped one.
    my @x[+@tmp-x;2] = @tmp-x.clone;
    my @y = @tmp-y.clone;
    (@x, @y)
  }

  my (@train-x, @train-y) := gen-train;
  my @test-x = 1 => 0.5e0, 2 => 0.5e0;
  my $libsvm = Algorithm::LibSVM.new;
  my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                    kernel-type => LINEAR);
  my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
  my $model = $libsvm.train($problem, $parameter);
  say $model.predict(features => @test-x)<label> # 1

=head1 DESCRIPTION

Algorithm::LibSVM is a Raku bindings for libsvm.

=head2 METHODS

=head3 cross-validation

Defined as:

       method cross-validation(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param, Int $nr-fold --> List)

Conducts C<$nr-fold>-fold cross validation and returns predicted values.

=head3 train

Defined as:

        method train(Algorithm::LibSVM::Problem $problem, Algorithm::LibSVM::Parameter $param --> Algorithm::LibSVM::Model)

Trains a SVM model.

=item C<$problem> The instance of Algorithm::LibSVM::Problem.

=item C<$param> The instance of Algorithm::LibSVM::Parameter.

=head3 B<DEPRECATED> load-problem

Defined as:

        multi method load-problem(\lines --> Algorithm::LibSVM::Problem)
        multi method load-problem(Str $filename --> Algorithm::LibSVM::Problem)

Loads libsvm-format data.

=head3 load-model

Defined as:

        method load-model(Str $filename --> Algorithm::LibSVM::Model)

Loads libsvm model.

=head3 evaluate

Defined as:

        method evaluate(@true-values, @predicted-values --> Hash)

Evaluates the performance of the three metrics (i.e. accuracy, mean squared error and squared correlation coefficient)

=item C<@true-values> The array that contains ground-truth values.

=item C<@predicted-values> The array that contains predicted values.

=head3 nr-feature

Defined as:

        method nr-feature(--> Int:D)

Returns the maximum index of all the features.

=head2 ROUTINES

=head3 parse-libsvmformat

Defined as:

        sub parse-libsvmformat(Str $text --> List) is export

Is a helper routine for handling libsvm-format text.

=head1 CAUTION

=head2 DON'T USE C<PRECOMPUTED> KERNEL

As a workaround for L<RT130187|https://rt.perl.org/Public/Bug/Display.html?id=130187>, I applied the patch programs (e.g. L<src/3.22/svm.cpp.patch>) for the sake of disabling random access of the problematic array.

Sadly to say, those patches drastically increase the complexity of using C<PRECOMPUTED> kernel.

=head1 SEE ALSO

=item libsvm L<https://github.com/cjlin1/libsvm>

=item RT130187 L<https://rt.perl.org/Public/Bug/Display.html?id=130187>

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
