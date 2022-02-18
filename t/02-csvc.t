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
    my @x[+@tmp-x;2] = @tmp-x.clone;
    my @y = @tmp-y.clone;
    (@x, @y)
}

my (@train-x, @train-y) := gen-train;
my @test-x = 1 => 0.5e0, 2 => 0.5e0;
my @text-y = [1];

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => LINEAR);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/LINEAR");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-x)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/LINEAR");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => LINEAR,
                                                      :probability);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/LINEAR/:probability");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-x, :probability)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/LINEAR/:probability");
    ok $model.predict(features => @test-x, :probability)<prob-estimates>[0] > 0.25e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<prob-estimates> predicts a probability that given instance (where the instance is at the center of the cluster labeled as 1 in the training set) is labeled as 1, it should return a value larger than 0.25e0" }("C_SVC/LINEAR/:probability");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => POLY);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/POLY");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-x)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/POLY");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => POLY,
                                                      :probability);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/POLY/:probability");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-x, :probability)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/POLY/:probability");
    ok $model.predict(features => @test-x, :probability)<prob-estimates>[0] > 0.25e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<prob-estimates> predicts a probability that given instance (where the instance is at the center of the cluster labeled as 1 in the training set) is labeled as 1, it should return a value larger than 0.25e0" }("C_SVC/POLY/:probability");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => RBF);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/RBF");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-x)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/RBF");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => RBF,
                                                      :probability);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/RBF/:probability");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-x, :probability)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/RBF/:probability");
    ok $model.predict(features => @test-x, :probability)<prob-estimates>[0] > 0.25e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<prob-estimates> predicts a probability that given instance (where the instance is at the center of the cluster labeled as 1 in the training set) is labeled as 1, it should return a value larger than 0.25e0" }("C_SVC/RBF/:probability");
}


{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => SIGMOID);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/SIGMOID");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-x)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/SIGMOID");
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => SIGMOID,
                                                      :probability);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/SIGMOID/:probability");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @test-x, :probability)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/SIGMOID/:probability");
    ok $model.predict(features => @test-x, :probability)<prob-estimates>[0] > 0.25e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<prob-estimates> predicts a probability that given instance (where the instance is at the center of the cluster labeled as 1 in the training set) is labeled as 1, it should return a value larger than 0.25e0" }("C_SVC/SIGMOID/:probability");
}

{
    my ($nrow, $ncol) = @train-x.shape;
    my @precomp-train-x[$nrow;$nrow];
    for ^$nrow X ^$nrow -> ($i, $j) {
        @precomp-train-x[$i;$j] = @train-x[$i;0] * @train-x[$j;0] + @train-x[$i;1] * @train-x[$j;1];
    }
    my $target-row = @train-y.pairs.grep(*.value == 1).head.key;
    my @precomp-test-x = gather for ^$nrow -> $i {
        if $i == 0 {
            take $i => $target-row + 1;
        }
        take $i + 1 => @precomp-train-x[$target-row;$i];
    }
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC,
                                                      kernel-type => PRECOMPUTED);
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-kernel-matrix(@precomp-train-x, @train-y);
    ok $libsvm.check-parameter($problem, $parameter), { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM.check-parameter should return True" }("C_SVC/PRECOMPUTED");
    my $model = $libsvm.train($problem, $parameter);
    is $model.predict(features => @precomp-test-x)<label>, 1.0e0, { "Given a setting of " ~ $_ ~ ", When Algorithm::LibSVM::Model.predict<label> predicts a label of a instance (where the instance is at the center of the cluster labeled as 1 in the training set), it should return 1.0e0" }("C_SVC/PRECOMPUTED");
}

done-testing;
