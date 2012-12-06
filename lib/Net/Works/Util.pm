package Net::Works::Util;

use strict;
use warnings;

use Math::Int128 qw( net_to_uint128 );
use NetAddr::IP::Util qw( bcd2bin bin2bcd );
use Socket qw( AF_INET AF_INET6 inet_pton inet_ntop );
use Scalar::Util qw( blessed );

use Exporter qw( import );

our @EXPORT_OK = qw(
    _string_address_to_integer
    _integer_address_to_binary
    _binary_address_to_string
    _integer_address_to_string
);

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

# ABSTRACT: Utility subroutines for Net-Works

__END__

=head1 DESCRIPTION

All of the subroutines in this module are really just for our internal use. No
peeking.

=cut
