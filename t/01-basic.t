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

done-testing;
