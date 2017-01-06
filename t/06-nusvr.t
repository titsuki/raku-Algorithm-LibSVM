use v6;
use Test;
use Algorithm::LibSVM;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Model;

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => NU_SVR,
                                                      kernel-type => LINEAR);
    my @train = (1..100).map: { ((2.0 * $_),"1:$_").join(" ") };
    my Algorithm::LibSVM::Problem $problem = $libsvm.load-problem(@train);
    my $model = $libsvm.train($problem, $parameter);
    my Pair @test = @train.map(*.split(" ")[1]).pick.split(" ")>>.split(":").map: { .[0].Int => .[1].Num };
    my $actual = $model.predict(features => @test)<label>;
    my $expected = 2.0 * @test[0].value;
    ok $expected - 0.1e0 <= $actual <= $expected + 0.1e0;
}

done-testing;
