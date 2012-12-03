package Net::Works::Types::Internal;

use strict;
use warnings;
use namespace::autoclean;

use Moose::Util::TypeConstraints;

class_type('Math::BigInt');

subtype 'PackedBinary'
=> as 'Value';

subtype 'IPInt'
=> as 'Int|Math::BigInt';

subtype 'IPVersion'
=> as 'Int';

coerce 'IPVersion', from 'Math::BigInt', via { $_->numify };
