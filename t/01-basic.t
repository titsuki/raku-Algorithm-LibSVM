use v6;
use Test;
use Algorithm::LibSVM;
use Algorithm::LibSVM::Parameter;
use Algorithm::LibSVM::Model;

{
    lives-ok { my $libsvm = Algorithm::LibSVM.new };
}

done-testing;
