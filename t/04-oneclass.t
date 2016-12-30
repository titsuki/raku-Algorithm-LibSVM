use v6;
use Test;
use Algorithm::LibSVM;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Model;


my @train = (q:to/END/).split("\n", :skip-empty);
+1 1:0.25 2:0.20
+1 1:0.25 2:0.25
+1 1:0.20 2:0.20
+1 1:0.20 2:0.25
+1 1:0.24 2:0.21
+1 1:0.24 2:0.24
+1 1:0.21 2:0.21
+1 1:0.21 2:0.24
+1 1:0.23 2:0.22
+1 1:0.23 2:0.23
+1 1:0.22 2:0.22
+1 1:0.22 2:0.23
-1 1:-0.25 2:0.20
-1 1:-0.25 2:0.25
END

my Pair @test = (q:to/END/).split(" ", :skip-empty)>>.split(":").map: { .[0].Int => .[1].Num };
1:0.22 2:0.22
END

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => ONE_CLASS,
                                                      kernel-type => RBF);
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    ok $libsvm.check-parameter($problem, $parameter), "ONE_CLASS/RBF";
    my $model = $libsvm.train($problem, $parameter);
    nok $libsvm.check-probability-model($model);
    is $model.predict(features => @test)<label>, 1.0e0;
}

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => ONE_CLASS,
                                                      kernel-type => PRECOMPUTED);

    my sub rbf($gamma, @lhs, @rhs) {
        my $inner = 0;
        my $lhs-inner = 0;
        my $rhs-inner = 0;
        $inner += @lhs[$_] * @rhs[$_] for ^@lhs;
        $lhs-inner += @lhs[$_] * @lhs[$_] for ^@lhs;
        $rhs-inner += @rhs[$_] * @rhs[$_] for ^@rhs;
        return exp(-$gamma * ($lhs-inner + $rhs-inner - 2.0 * $inner))
    };

    my @tmp = @train>>.split(" ", :skip-empty);
    my Str @train-matrix = gather for @tmp.pairs -> (:key($index-f), :value(@x)) {
        my $f1 = @x[1].split(":")[0] => @x[1].split(":")[1];
        my $f2 = @x[2].split(":")[0] => @x[2].split(":")[1];
        
        my @result;
        @result.push(@x[0]);
        @result.push(0 ~ ":" ~ $index-f + 1);
        for @tmp.pairs -> (:key($index-t), :value(@y)) {
            my $t1 = @y[1].split(":")[0] => @y[1].split(":")[1];
            my $t2 = @y[2].split(":")[0] => @y[2].split(":")[1];
            @result.push($index-t + 1 ~ ":" ~  rbf($parameter.gamma,
                                                   ($f1.value, $f2.value),
                                                   ($t1.value, $t2.value)));
        }
        take @result.join(" ");
    }
    # @train-matrix[10] == 0.22 0.22
    my Pair @test-matrix = @train-matrix[10]\
    .split(" ", 2, :skip-empty)[1].split(" ")>>.split(":").map: { .[0].Int => .[1].Num };

    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train-matrix);
    ok $libsvm.check-parameter($problem, $parameter), "ONE_CLASS/PRECOMPUTED";
    my $model = $libsvm.train($problem, $parameter);
    nok $libsvm.check-probability-model($model);
    is $model.predict(features => @test-matrix)<label>, 1.0e0;
}

done-testing;
