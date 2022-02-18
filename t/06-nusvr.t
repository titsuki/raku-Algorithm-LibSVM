use v6;
use Test;
use Algorithm::LibSVM;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Problem;
use Algorithm::LibSVM::Model;

{
    my $libsvm = Algorithm::LibSVM.new;
    my Algorithm::LibSVM::Parameter $parameter .= new(svm-type => NU_SVR,
                                                      kernel-type => LINEAR,
                                                      :probability);
    my @train-x[100;1] = (1..100).map: { [$_] };
    my @train-y = (1..100).map: { 2.0 * $_ };
    my Algorithm::LibSVM::Problem $problem = Algorithm::LibSVM::Problem.from-matrix(@train-x, @train-y);
    my $model = $libsvm.train($problem, $parameter);
    my @test-x = 1 => @train-x[0;0];
    my $actual = $model.predict(features => @test-x)<label>;
    my $expected = 2.0 * @test-x[0].value;
    my $mae = $model.svr-probability;
    my $std = sqrt(2.0 * $mae * $mae);
    ok $expected - 5.0 * $std <= $actual <= $expected + 5.0 * $std, { "Given a setting of " ~ $_ ~ ", Algorithm::LibSVM::Model.predict<label> should predict f(x)" }("NU_SVR/LINEAR");
}

done-testing;
