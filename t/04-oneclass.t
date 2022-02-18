use v6;
use Test;
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
            when $x ** 2 + $y ** 2 <= 0.3 ** 2 {
                1
            }
            default { Nil }
        }
        if $label.defined {
            @tmp-y.push: $label;
            @tmp-x.push: [$x, $y];
        }
    }
    my @x[+@tmp-x;2] = @tmp-x.clone;
    my @y = @tmp-y.clone;
    (@x, @y)
}

my (@train-x, @train-y) := gen-train;

my Pair @test-in = [1 => sqrt(0), 2 => sqrt(0)];
my Pair @test-out = [1 => sqrt(10), 2 => sqrt(10)];

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => ONE_CLASS,
                                                      kernel-type => RBF,
                                                      nu => 1e-2);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("ONE_CLASS/RBF");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-in)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center in the training set), it should return 1.0e0" }("ONE_CLASS/RBF");
    is $model.predict(features => @test-out)<label>, -1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance keeps at a distance from the center in the training set), it should return -1.0e0" }("ONE_CLASS/RBF");
}

done-testing;
