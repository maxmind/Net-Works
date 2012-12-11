#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage"
    if $@;

eval "use Pod::Coverage::Moose 0.02";
plan skip_all => "Pod::Coverage::Moose 0.02 required for testing POD coverage"
    if $@;

my %skip = map { $_ => 1 } qw(
    Net::Works::Role::IP
    Net::Works::Types
    Net::Works::Types::Internal
);

my @modules = grep { ! $skip{$_} } all_modules();

for my $module ( sort @modules ) {
    pod_coverage_ok(
        $module,
        {
            coverage_class => 'Pod::Coverage::Moose',
            trustme        => [qr/^BUILD$/],
        },
        "Pod coverage for $module"
    );
}

done_testing();
