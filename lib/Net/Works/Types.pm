package Net::Works::Types;

use strict;
use warnings;

use parent 'MooseX::Types::Combine';

__PACKAGE__->provide_types_from(
    qw(
        MooseX::Types::Moose
        Net::Works::Types::Internal
        )
);

1;
