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

all_pod_coverage_ok({ coverage_class => 'Pod::Coverage::Moose'});

done_testing();
