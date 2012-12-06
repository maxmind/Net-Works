package Net::Works::Role::IP;

use strict;
use warnings;
use namespace::autoclean;

use Math::Int128 qw(uint128 net_to_uint128 uint128_to_net);
use Net::Works::Types qw( Int IPVersion );
use NetAddr::IP::Util qw( bcd2bin bin2bcd );
use Socket qw( AF_INET AF_INET6 inet_pton inet_ntop );
use Scalar::Util qw( blessed );

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

sub _string_address_to_integer {
    my $string  = shift;
    my $version = shift;

    my $binary = inet_pton( $version == 4 ? AF_INET : AF_INET6, $string );

    return $version == 4
        ? unpack( N => $binary )
        : net_to_uint128($binary);
}

sub _integer_address_to_binary {
    my $integer = shift;

    # Note: there seems to be a bug in uint128_to_net that causes a byte
    # to be flipped as of Dec. 6, 2012. Using bcd2bin instead.
    if ( ref $integer && blessed $integer) {
        return bcd2bin($integer);
    }
    else {
        return pack( N => $integer );
    }
}

sub _binary_address_to_string {
    my $binary = shift;

    my $family = length($binary) == 4 ? AF_INET : AF_INET6;

    return inet_ntop( $family, $binary );
}

sub _integer_address_to_string {
    _binary_address_to_string( _integer_address_to_binary( $_[0] ) );
}

1;
