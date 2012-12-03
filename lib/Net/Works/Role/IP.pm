package Net::Works::Role::IP;

use strict;
use warnings;
use namespace::autoclean;

use Data::Validate::IP qw(is_ipv4);
use Math::BigInt try => 'GMP';
use Net::Works::Types::Internal;
use NetAddr::IP::Util qw(bin2bcd);
use Socket qw(inet_pton AF_INET AF_INET6);

use Moose::Role;

sub _max {
    my $self = shift;
    my $version = shift // $self->version;

    return $version == 4
        ? 0xFFFFFFFF
        : Math::BigInt->from_hex('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
}

sub _string_to_integer {
    my $address = shift;

    if ( is_ipv4($address) ) {
        return unpack 'N', inet_pton( AF_INET, $address );
    }
    else {
        return Math::BigInt->new(
            bin2bcd( inet_pton( AF_INET6, $address ) ) );
    }
}

1;
