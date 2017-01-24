use v6;
use NativeCall;
use NativeHelpers::Array;

unit class Algorithm::LibSVM::Parameter is export is repr('CStruct');

my constant $library = %?RESOURCES<libraries/svm>.Str;

enum SVMType is export <C_SVC NU_SVC ONE_CLASS EPSILON_SVR NU_SVR>;
enum KernelType is export <LINEAR POLY RBF SIGMOID PRECOMPUTED>;

has int32 $!svm_type;
has int32 $!kernel_type;
has int32 $!degree;
has num64 $!gamma;
has num64 $!coef0;
has num64 $!cache_size;
has num64 $!eps;
has num64 $!C;
has int32 $!nr_weight;
has CArray[int32] $!weight_label;
has CArray[num64] $!weight;
has num64 $!nu;
has num64 $!p;
has int32 $!shrinking;
has int32 $!probability;

submethod BUILD(SVMType :$svm-type?,
                KernelType :$kernel-type?,
                Num :$gamma?,
                Num :$coef0?,
                Num :$cache-size?,
                Num :$eps?,
                Num :$C?,
                Int :$nr-weight?,
                :@weight-label?,
                :@weight?,
                Int :$degree?,
                Num :$nu?,
                Num :$p?,
                Bool :$shrinking?,
                Bool :$probability?)
{
    $!svm_type = $svm-type // C_SVC;
    $!kernel_type = $kernel-type // RBF;
    $!gamma = $gamma // 0e0;
    $!coef0 = $coef0 // 0e0;
    $!cache_size = $cache-size // 100e0;
    $!eps = $eps // 1e-3;
    $!C = $C // 1e0;
    $!nr_weight = $nr-weight // 0;
    $!weight_label := CArray[int32].new; $!weight_label[$_] = @weight-label[$_] for ^@weight-label;
    $!weight := CArray[num64].new; $!weight[$_] = @weight[$_] for ^@weight;
    $!degree = $degree // 3;
    $!nu = $nu // 0.5e0;
    $!p = $p // 0.1e0;
    $!shrinking = $shrinking // 1;
    $!probability = $probability // 0;
}

multi method svm-type(SVMType $svm-type) {
    $!svm_type = $svm-type;
}

multi method svm-type {
    $!svm_type
}

multi method kernel-type(KernelType $kernel-type) {
    $!kernel_type = $kernel-type;
}

multi method kernel-type {
    $!kernel_type
}

multi method degree(Int:D $degree) {
    $!degree = $degree;
}

multi method degree {
    $!degree
}

multi method gamma(Num:D $gamma) {
    $!gamma = $gamma;
}

multi method gamma {
    $!gamma
}

multi method coef0(Num:D $coef0) {
    $!coef0 = $coef0;
}

multi method coef0 {
    $!coef0
}

multi method cache-size(Num:D $cache-size) {
    $!cache_size = $cache-size;
}

multi method cache-size {
    $!cache_size
}

multi method eps(Num:D $eps) {
    $!eps = $eps;
}

multi method eps {
    $!eps
}

multi method C(Num:D $C) {
    $!C = $C;
}

multi method C {
    $!C
}

multi method nr-weight(Int:D $nr-weight) {
    $!nr_weight = $nr-weight;
}

multi method nr-weight {
    $!nr_weight
}

# TODO: setter for weight-label, weight

method weight-label {
    copy-to-array($!weight_label, $!nr_weight);
}

method weight {
    copy-to-array($!weight, $!nr_weight);
}

multi method nu(Num:D $nu) {
    $!nu = $nu;
}

multi method nu {
    $!nu
}

multi method p(Num:D $p) {
    $!p = $p;
}

multi method p {
    $!p
}

multi method shrinking(Bool:D $shrinking) {
    $!shrinking = $shrinking ?? 1 !! 0;
}

multi method shrinking returns Bool {
    Bool($!shrinking)
}

multi method probability(Bool:D $probability) {
    $!probability = $probability ?? 1 !! 0;
}

multi method probability returns Bool {
    Bool($!probability)
}

my sub svm_destroy_param(Algorithm::LibSVM::Parameter) is native($library) { * }

submethod DESTROY {
    svm_destroy_param(self);
}

=begin pod

=head1 NAME

Algorithm::LibSVM::Parameter - A Perl 6 Algorithm::LibSVM::Parameter class

=head1 SYNOPSIS

  use Algorithm::LibSVM::Parameter;

=head1 DESCRIPTION

Algorithm::LibSVM::Parameter is a Perl 6 Algorithm::LibSVM::Parameter class

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the terms of the MIT License.

libsvm ( https://github.com/cjlin1/libsvm ) by Chih-Chung Chang and Chih-Jen Lin is licensed under the BSD 3-Clause License.

=end pod
