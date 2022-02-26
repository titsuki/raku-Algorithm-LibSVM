use v6;
use NativeCall;
use Algorithm::LibSVM::Node;
use Algorithm::LibSVM::Parameter;

unit class Algorithm::LibSVM::Model:ver<0.0.15> is export is repr('CPointer'); 

my constant $library = %?RESOURCES<libraries/svm>.Str;

my sub svm_get_svm_type(Algorithm::LibSVM::Model --> int32) is native($library) { * }
my sub svm_get_nr_class(Algorithm::LibSVM::Model --> int32) is native($library) { * }
my sub svm_get_labels(Algorithm::LibSVM::Model, CArray[int32]) is native($library) { * }
my sub svm_get_sv_indices(Algorithm::LibSVM::Model, CArray[int32]) is native($library) { * }
my sub svm_get_nr_sv(Algorithm::LibSVM::Model --> int32) is native($library) { * }
my sub svm_get_svr_probability(Algorithm::LibSVM::Model --> num64) is native($library) { * }
my sub svm_predict_values(Algorithm::LibSVM::Model, Algorithm::LibSVM::Node, CArray[num64] --> num64) is native($library) { * }
my sub svm_predict(Algorithm::LibSVM::Model, Algorithm::LibSVM::Node --> num64) is native($library) { * }
my sub svm_predict_probability(Algorithm::LibSVM::Model, Algorithm::LibSVM::Node, CArray[num64] --> num64) is native($library) { * }
my sub svm_free_model_content(Algorithm::LibSVM::Model) is native($library) { * }
my sub svm_free_and_destroy_model(Algorithm::LibSVM::Model) is native($library) { * }
my sub svm_check_probability_model(Algorithm::LibSVM::Model --> int32) is native($library) { * }

sub svm_save_model(Str, Algorithm::LibSVM::Model) is native($library) is export { * }

method save(Str $filename) {
    svm_save_model($filename, self)
}

method svm-type(--> SVMType) {
    SVMType(svm_get_svm_type(self))
}

method nr-class(--> Int:D) {
    svm_get_nr_class(self)
}

method labels(--> List) {
    my $labels = CArray[int32].allocate: self.nr-class;
    svm_get_labels(self, $labels);
    $labels.list
}

method sv-indices(--> List) {
    my $indices = CArray[int32].allocate: self.nr-sv;
    svm_get_sv_indices(self, $indices);
    $indices.list
}

method nr-sv(--> Int:D) {
    svm_get_nr_sv(self)
}

method svr-probability(--> Num:D) {
    svm_get_svr_probability(self)
}

method !make-node-linked-list(:$features --> Algorithm::LibSVM::Node) {
    my Algorithm::LibSVM::Node $next .= new(index => -1, value => 0e0);
    for @($features).sort({ $^b.key <=> $^a.key }) {
        $next = Algorithm::LibSVM::Node.new(index => .key, value => .value.Num, next => $next);
    }
    $next;
}

method predict(:$features where { .all ~~ Pair }, Bool :$probability, Bool :$decision-values --> Hash) {
    my %result;
    if $probability and self.check-probability-model {
        my $prob-estimates = CArray[num64].allocate: self.nr-class;
        my $label = svm_predict_probability(self, self!make-node-linked-list(:$features), $prob-estimates);
        %result<label> = $label;
        %result<prob-estimates> = $prob-estimates.list;
    }
    if $decision-values {
        my $dec-values = CArray[num64].allocate: self.nr-class * (self.nr-class - 1) div 2;
        my $label = svm_predict_values(self, self!make-node-linked-list(:$features), $dec-values);
        %result<label> = $label;
        %result<decision-values> = $dec-values.list;
    }

    if not $probability and not $decision-values {
        %result<label> = svm_predict(self, self!make-node-linked-list(:$features));
    }
    %result;
}

method check-probability-model(--> Bool) {
    my $ok = Bool(svm_check_probability_model(self) == 0 ?? False !! True);
    if not $ok {
        die "ERROR: Given model cannot compute probability.";
    }
    $ok;
}

# submethod DESTROY {
#     svm_free_and_destroy_model(self)
# }

=begin pod

=head1 NAME

Algorithm::LibSVM::Model - A Raku Algorithm::LibSVM::Model class

=head1 SYNOPSIS

  use Algorithm::LibSVM::Model;

=head1 DESCRIPTION

Algorithm::LibSVM::Model is a Raku Algorithm::LibSVM::Model class

=head2 METHODS

=head3 save

Defined as:

        method save(Str $filename)

Saves the model to the file C<$filename>.

=head3 svm-type

Defined as:

        method svm-type(--> SVMType)

Returns the C<SVMType> object.

=head3 nr-class

Defined as:

        method nr-class(--> Int:D)

Returns the number of the classes.

=head3 labels

Defined as:

        method labels(--> List)

Returns the labels.

=head3 sv-indices

Defined as:

        method sv-indices(--> List)

Returns the indices of the support vectors.

=head3 nr-sv

Defined as:

        method nr-sv(--> Int:D)

Returns the number of the support vectors.

=head3 svr-probability

Defined as:

        method svr-probability(--> Num:D)

Returns the probability predicted by support vector regression.

=head3 predict

Defined as:

        method predict(:$features where { .all ~~ Pair }, Bool :$probability, Bool :$decision-values --> Hash)

Conducts the prediction and returns its results.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
