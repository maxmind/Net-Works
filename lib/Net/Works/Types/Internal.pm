package Net::Works::Types::Internal;

use strict;
use warnings;
use namespace::autoclean;

use MooseX::Types -declare => [
    qw(
        BigInt
        UInt128
        PackedBinary
        IPInt
        IPVersion
        )
];

use MooseX::Types::Moose qw( Int Value );

class_type BigInt, { class => 'Math::BigInt' };
class_type UInt128, { class => 'Math::UInt128' };

subtype PackedBinary,
    as Value;

subtype IPInt,
    as Int|UInt128;

subtype IPVersion,
    as Int;

coerce IPVersion,
    from BigInt,
    via { $_->numify() };

1;
