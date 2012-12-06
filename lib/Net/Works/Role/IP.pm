package Net::Works::Role::IP;

use strict;
use warnings;
use namespace::autoclean;

use Math::Int128 qw( uint128 );
use Net::Works::Types qw( Int IPVersion );
use Socket qw( AF_INET AF_INET6 );

use Moose::Role;

use integer;

has version => (
    is       => 'ro',
    isa      => IPVersion,
    required => 1,
    coerce   => 1,
);

has address_family => (
    is      => 'ro',
    isa     => Int,
    lazy    => 1,
    default => sub { $_[0]->version() == 6 ? AF_INET6 : AF_INET },
);

{
    my %max = (
        4 => 0xFFFFFFFF,
        6 => uint128(0) - 1,
    );

    sub _max {
        my $self = shift;
        my $version = shift // $self->version();

        return $max{$version};
    }
}

sub bits { $_[0]->version() == 6 ? 128 : 32 }

1;
