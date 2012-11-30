package Net::Works::Role::IP;

use strict;
use warnings;
use namespace::autoclean;

use Moose::Role;

sub _max {
    $_[0]->version == 4
        ? 0xFFFFFFFF
        : Math::BigInt->from_hex('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
}

1;
