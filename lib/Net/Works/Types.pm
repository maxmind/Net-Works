package Net::Works::Types;

use strict;
use warnings;

use Exporter qw( import );
use MooX::Types::MooseLike;
use Scalar::Util qw( blessed );

my @types = (
    {
        name    => 'PackedBinary',
        test    => sub { defined $_[0] && !ref $_[0] },
        message => sub { _m( '%s is not binary data', $_[0] ) },
    },
    {
        name => 'IPInt',
        test => sub {
            return 0 unless defined $_[0];
            return 1 if !ref $_[0] && $_[0] =~ /^[0-9]+$/;
            return 1
                if blessed( $_[0] ) && $_[0]->isa('Math::UInt128');
            return 0;
        },
        message => sub {
            _m( '%s is not a valid integer for an IP address', $_[0] );
        },
    },
    {
        name => 'IPVersion',
        test => sub {
            defined $_[0]
                && !ref $_[0]
                && ( $_[0] == 4
                || $_[0] == 6 );
        },
        message =>
            sub { _m( '%s is not a valid IP version (4 or 6)', $_[0] ) },
    },
    {
        name => 'MaskLength',
        test => sub {
            !ref $_[0] && $_[0] >= 0 && $_[0] <= 128;
        },
        message => sub {
            _m(
                '%s is not a valid IP network mask length (0-128)',
                $_[0]
            );
        },
    },
);

MooX::Types::MooseLike::register_types( \@types, __PACKAGE__ );

sub _m {
    return sprintf(
        $_[0],
        defined $_[1] ? $_[1] : 'undef'
    );
}

1;
