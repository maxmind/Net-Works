package Net::Works::Role::IP;

use strict;
use warnings;
use namespace::autoclean;

use Data::Validate::IP qw(is_ipv4);
use Math::BigInt try => 'GMP';
use NetAddr::IP::Util qw(bin2bcd);
use Socket qw(inet_pton AF_INET AF_INET6);

use Moose::Role;

# This is needed as Math::BigInts are sneaking in as Ints.
# Maybe create a separate type library with an actual IP version type.
use Moose::Util::TypeConstraints;
class_type('Math::BigInt');
# FIX - apparently type coercions are global
coerce 'Int', from 'Math::BigInt', via { $_->numify };

sub _max {
    $_[0]->version == 4
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
