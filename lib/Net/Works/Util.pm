package Net::Works::Util;

use strict;
use warnings;

use Carp qw( confess );
use Math::Int128 qw( net_to_uint128 uint128_to_net );
use Socket qw( AF_INET AF_INET6 inet_pton inet_ntop );
use Scalar::Util qw( blessed );

use Exporter qw( import );

our @EXPORT_OK = qw(
    _string_address_to_integer
    _integer_address_to_binary
    _binary_address_to_string
    _integer_address_to_string
    _validate_ip_string
);

sub _string_address_to_integer {
    my $string  = shift;
    my $version = shift;

    my $binary = inet_pton( $version == 4 ? AF_INET : AF_INET6, $string )
        or return;

    return $version == 4
        ? unpack( N => $binary )
        : net_to_uint128($binary);
}

sub _integer_address_to_binary {
    my $integer = shift;

    if ( ref $integer && blessed $integer) {
        return uint128_to_net($integer);
    }
    else {
        return pack( N => $integer );
    }
}

sub _binary_address_to_string {
    my $binary = shift;

    my $family = length($binary) == 4 ? AF_INET : AF_INET6;

    my $string = inet_ntop( $family, $binary );
    return $string eq '::' ? '::0' : $string;
}

sub _integer_address_to_string {
    _binary_address_to_string( _integer_address_to_binary( $_[0] ) );
}

sub _validate_ip_string {
    my $str     = shift;
    my $version = shift;

    my $str_val = defined $str ? $str : 'undef';
    if ( $version == 4 ) {
        confess("$str_val is not a valid IPv4 address")
            unless defined $str && defined inet_pton( AF_INET, $str );
    }
    else {
        confess("$str_val is not a valid IPv6 address")
            unless defined $str && defined inet_pton( AF_INET6, $str );
    }
}

1;

# ABSTRACT: Utility subroutines for Net-Works

__END__

=head1 DESCRIPTION

All of the subroutines in this module are really just for our internal use. No
peeking.

=cut
