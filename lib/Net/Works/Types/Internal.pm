package Net::Works::Types::Internal;

use strict;
use warnings;
use namespace::autoclean;

use MooseX::Types -declare => [
    qw(
        IPInt
        IPVersion
        MaskLength
        PackedBinary
        UInt128
        )
];

use MooseX::Types::Moose qw( Int Str );

class_type UInt128, { class => 'Math::UInt128' };

subtype PackedBinary,
    as Str;

subtype IPInt,
    as Int | UInt128,
    where { $_ >= 0 },
    inline_as { $_[0]->parent()->_inline_check( $_[1] ) . " && ($_[1] >= 0)" },
    message { ( defined $_ ? $_ : 'undef' ) . ' is not a valid IP integer' };

subtype IPVersion,
    as Int;

subtype MaskLength,
    as Int,
    where { $_ >= 0 && $_ <= 128 },
    inline_as {
        $_[0]->parent()->_inline_check( $_[1] )
            . " && ($_[1] >= 0 && $_[1] <= 128)";
    },
    message {
        ( defined $_ ? $_ : 'undef' ) . ' is not a valid IP mask length';
    };

1;
