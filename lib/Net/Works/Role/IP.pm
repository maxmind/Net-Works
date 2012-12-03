package Net::Works::Role::IP;

use strict;
use warnings;
use namespace::autoclean;

use Math::BigInt try => 'GMP';
use Net::Works::Types::Internal;
use Socket qw( AF_INET AF_INET6 );

use Moose::Role;

has version => (
    is       => 'ro',
    isa      => 'IPVersion',
    required => 1,
    coerce   => 1,
);

has address_family => (
    is      => 'ro',
    isa     => 'Int',
    lazy    => 1,
    default => sub { $_[0]->version == 6 ? AF_INET6 : AF_INET },
);


sub _max {
    my $self = shift;
    my $version = shift // $self->version;

    return $version == 4
        ? 0xFFFFFFFF
        : Math::BigInt->from_hex('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
}

1;
