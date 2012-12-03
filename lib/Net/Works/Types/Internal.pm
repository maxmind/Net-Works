package Net::Works::Types::Internal;

use strict;
use warnings;
use namespace::autoclean;

use Moose::Util::TypeConstraints;

class_type('Math::BigInt');

subtype 'PackedBinary'
=> as 'Value';

subtype 'IPInt'
=> as 'Defined';

subtype 'IPVersion'
=> as 'Int|Math::BigInt'
=> where { $_ == 4 || $_ == 6};

coerce 'IPVersion', from 'Math::BigInt', via { $_->numify };
