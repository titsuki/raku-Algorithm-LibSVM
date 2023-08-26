use v6;
use Test;
use Algorithm::LibSVM;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Model;

{
    lives-ok { my $libsvm = Algorithm::LibSVM.new }, "Algorithm::LibSVM.new should create a instance";
}

{
    lives-ok { my $libsvm = Algorithm::LibSVM.new.load-problem(("1 1:0 # comment",)) }, "Algorithm::LibSVM.load-problem should read lines include comments";
}

{
    lives-ok { my $p = Algorithm::LibSVM::Problem.from-file("{$*PROGRAM.parent}/australian"); }, "Algorithm::LibSVM::Problem.from-file should create an instance from the libsvm format file ";
}

{
    lives-ok {
        my @y = [1 xx 100, 0 xx 100]>>.List.flat;
        # y:    0       0       1
        # x: [1 0 1] [1 0 1] [1 1 1]
        my @x[200;3] = gather for ^@y { if $_ == 1 { take [1, 1, 1] } else { take [1, 0, 1] } };
        my $libsvm = Algorithm::LibSVM.new;
        my $problem = Algorithm::LibSVM::Problem.from-matrix(@x, @y);
        my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC, kernel-type => RBF);
        my @r = $libsvm.cross-validation($problem, $parameter, 10);
        $libsvm.evaluate($problem.y, @r);
    }, "Algorithm::LibSVM::Problem.from-matrix should create an instance from a shaped 2d @x and an 1d @y.";
}

{
    lives-ok {
        my @y = [1 xx 100, 0 xx 100]>>.List.flat;
        # y:    0       0       1
        # x: [1 0 1] [1 0 1] [1 1 1]
        my @x = gather for ^@y { if $_ == 1 { take [1, 1, 1] } else { take [1, 0, 1] } };
        my $libsvm = Algorithm::LibSVM.new;
        my $problem = Algorithm::LibSVM::Problem.from-matrix(@x, @y);
        my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC, kernel-type => RBF);
        my @r = $libsvm.cross-validation($problem, $parameter, 10);
        $libsvm.evaluate($problem.y, @r);
    }, "Algorithm::LibSVM::Problem.from-matrix should create an instance from an unshaped @x and an 1d @y.";
}

{
    lives-ok {
        my @lines = (("1 1:0" xx 100), ("0 1:1" xx 100)).flat;
        my $libsvm = Algorithm::LibSVM.new;
        my $problem = $libsvm.load-problem(@lines);
        my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => C_SVC, kernel-type => RBF);
        my @r = $libsvm.cross-validation($problem, $parameter, 10);
        $libsvm.evaluate($problem.y, @r);
    }, "Make sure problem.y is feasible even if its instance was used by cross-validation (#55)";
}

done-testing;
