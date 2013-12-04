use strict;
use warnings;

use Test::More 0.88;

use Net::Works::Network;

{
    my $net = Net::Works::Network->new_from_string( string => '1.1.1.0/28' );

    is(
        $net->as_string(),
        '1.1.1.0/28',
        'as_string returns value passed to the constructor'
    );

    is(
        $net->mask_length(),
        28,
        'netmask is 28'
    );

    my $first = $net->first();
    isa_ok(
        $first,
        'Net::Works::Address',
        'return value of ->first'
    );

    is(
        $first->as_string(),
        '1.1.1.0',
        '->first returns the correct IP address'
    );

    my $last = $net->last();
    isa_ok(
        $last,
        'Net::Works::Address',
        'return value of ->last'
    );

    is(
        $last->as_string(),
        '1.1.1.15',
        '->last returns the correct IP address'
    );

    _test_iterator(
        $net,
        16,
        [ map { "1.1.1.$_" } 0 .. 15 ],
    );

    is(
        "$net",
        '1.1.1.0/28',
        'stringification of network object works'
    );
}

{
    my $net = Net::Works::Network->new_from_string( string => 'ffff::1200/120' );

    is(
        $net->as_string(),
        'ffff::1200/120',
        'as_string returns value passed to the constructor'
    );

    is(
        $net->mask_length(),
        120,
        'netmask is 120',
    );

    my $first = $net->first();
    isa_ok(
        $first,
        'Net::Works::Address',
        'return value of ->first'
    );

    is(
        $first->as_string(),
        'ffff::1200',
        '->first returns the correct IP address'
    );

    my $last = $net->last();
    isa_ok(
        $last,
        'Net::Works::Address',
        'return value of ->last'
    );

    is(
        $last->as_string(),
        'ffff::12ff',
        '->last returns the correct IP address'
    );

    _test_iterator(
        $net,
        256,
        [ map { sprintf( "ffff::12%02x", $_ ) } 0 .. 255 ],
    );
}

{
    my $net = Net::Works::Network->new_from_string( string => '1.1.1.1/32' );

    _test_iterator(
        $net,
        1,
        ['1.1.1.1'],
    );
}

{
    my $net = Net::Works::Network->new_from_string( string => '1.1.1.0/31' );

    _test_iterator(
        $net,
        2,
        [ '1.1.1.0', '1.1.1.1' ],
    );
}

{
    my $net = Net::Works::Network->new_from_string( string => '1.1.1.4/30' );

    _test_iterator(
        $net,
        4,
        [ '1.1.1.4', '1.1.1.5', '1.1.1.6', '1.1.1.7' ],
    );
}

{
    my %tests = (
        ( map { '100.99.98.0/' . $_ => 23 } 23 .. 32 ),
        ( map { '100.99.16.0/' . $_ => 20 } 20 .. 32 ),
        ( map { '1.1.1.0/' . $_     => 24 } 24 .. 32 ),
        ( map { 'ffff::/' . $_      => 16 } 16 .. 128 ),
        ( map { 'ffff:ff00::/' . $_ => 24 } 24 .. 128 ),
    );

    for my $subnet ( sort keys %tests ) {
        my $net = Net::Works::Network->new_from_string( string => $subnet );

        is(
            $net->max_mask_length(),
            $tests{$subnet},
            "max_mask_length for $subnet is $tests{$subnet}"
        );
    }
}

{
    my %contains = (
        '1.1.1.0/24' => {
            true => [
                qw( 1.1.1.0 1.1.1.1 1.1.1.254 1.1.1.254
                    1.1.1.0/24 1.1.1.0/26 1.1.1.255/32 )
            ],
            false => [
                qw( 1.1.2.0 1.1.0.255 240.1.2.3
                    1.1.0.0/16 1.1.0.0/24 11.12.13.14/32 )
            ],
        },
        '97.0.0.0/8' => {
            true => [
                qw( 97.0.0.0 97.1.2.3 97.200.201.203 97.255.255.254 97.255.255.255
                    97.9.0.0/24 97.55.0.0/16 97.0.0.0/8 97.255.255.255/32 )
            ],
            false => [
                qw( 96.255.255.255 98.0.0.0 1.1.1.32 240.1.2.3
                    96.0.0.0/4 98.0.0.0/8 11.12.13.14/32 )
            ],
        },
        '1000::/8' => {
            true => [
                qw( 1000:: 1000::1 10bc:def9:1234::0
                    10ff:ffff:ffff:ffff:ffff:ffff:ffff:fffe
                    10ff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
                    1000::/8 1000::/16 1034::1/128 10ff::/124
                    10ff:ffff:ffff:ffff:ffff:ffff:ffff:ffff/128 )
            ],
            false => [
                qw( 0fff:: 0fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
                    f::f 1100::
                    1000::/4 2000::/120 ffff::/128 )
            ],
        },
    );

    for my $n ( sort keys %contains ) {
        my $network = Net::Works::Network->new_from_string( string => $n );

        for my $string ( @{ $contains{$n}{true} } ) {
            my $object = _objectify_string($string);
            ok(
                $network->contains($object),
                $network->as_string() . ' contains ' . $object->as_string()
            );
        }

        for my $string ( @{ $contains{$n}{false} } ) {
            my $object = _objectify_string($string);
            ok(
                !$network->contains($object),
                $network->as_string()
                    . ' does not contain '
                    . $object->as_string()
            );
        }
    }
}

{
    my @splits = (
        [ '1.1.1.0/24'   => [ '1.1.1.0/25',   '1.1.1.128/25' ] ],
        [ '1.1.1.128/25' => [ '1.1.1.128/26', '1.1.1.192/26' ] ],
        [ '1.1.1.192/26' => [ '1.1.1.192/27', '1.1.1.224/27' ] ],
        [ '1.1.1.224/27' => [ '1.1.1.224/28', '1.1.1.240/28' ] ],
        [ '1.1.1.240/28' => [ '1.1.1.240/29', '1.1.1.248/29' ] ],
        [ '1.1.1.248/29' => [ '1.1.1.248/30', '1.1.1.252/30' ] ],
        [ '1.1.1.252/30' => [ '1.1.1.252/31', '1.1.1.254/31' ] ],
        [ '1.1.1.254/31' => [ '1.1.1.254/32', '1.1.1.255/32' ] ],
        [ '9000::/8'     => [ '9000::/9',     '9080::/9' ] ],
        [ '9080::/9'     => [ '9080::/10',    '90c0::/10' ] ],
        [ '90c0::/10'    => [ '90c0::/11',    '90e0::/11' ] ],
        [ '90e0::/11'    => [ '90e0::/12',    '90f0::/12' ] ],
        [ '90f0::/12'    => [ '90f0::/13',    '90f8::/13' ] ],
        [ '90f8::/13'    => [ '90f8::/14',    '90fc::/14' ] ],
        [ '90fc::/14'    => [ '90fc::/15',    '90fe::/15' ] ],
        [ '90fe::/15'    => [ '90fe::/16',    '90ff::/16' ] ],
    );

    for my $pair (@splits) {
        my $original
            = Net::Works::Network->new_from_string( string => $pair->[0] );
        my @halves = $original->split();

        is_deeply(
            [ map { $_->as_string() } $original->split() ],
            $pair->[1],
            "$pair->[0] splits into $pair->[1][0] and $pair->[1][1]"
        );
    }

    is_deeply(
        [
            Net::Works::Network->new_from_string( string => '1.1.1.1/32' )
                ->split()
        ],
        [],
        'split() returns an empty list for single address IPv4 network'
    );

    is_deeply(
        [
            Net::Works::Network->new_from_string(
                string => '9999::abcd/128'
            )->split()
        ],
        [],
        'split() returns an empty list for single address IPv6 network'
    );
}


{
    my $net = Net::Works::Network->new_from_string( string => '::/0' );

    is( $net->as_string(), '::/0', 'got subnet passed to constructor' );
    is(
        $net->first()->as_string(), '::',
        'first address in network is ::'
    );
}

sub _test_iterator {
    my $net              = shift;
    my $expect_count     = shift;
    my $expect_addresses = shift;

    my $iter = $net->iterator();

    my @addresses;
    while ( my $address = $iter->() ) {
        push @addresses, $address;
    }

    is(
        scalar @addresses,
        $expect_count,
        "iterator returned $expect_count addresses"
    );

    is_deeply(
        [ map { $_->as_string() } @addresses ],
        $expect_addresses,
        "iterator returned $expect_addresses->[0] - $expect_addresses->[-1]"
    );
}

sub _objectify_string {
    my $string = shift;

    return $string =~ m{/}
        ? Net::Works::Network->new_from_string( string => $string )
        : Net::Works::Address->new_from_string( string => $string );
}

done_testing();
