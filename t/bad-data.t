use strict;
use warnings;

use Math::Int128 qw( uint128 );
use Test::Fatal;
use Test::More 0.88;

use Net::Works::Address;
use Net::Works::Network;

{
    for my $bad_num ( undef, qw( -1 1.1 a-string google.com ), 2**33 ) {
        my $str_val = defined $bad_num ? $bad_num : 'undef';

        like(
            exception {
                Net::Works::Address->new_from_integer(
                    integer => $bad_num,
                    version => 4,
                );
            },
            qr/\Q$str_val is not a valid IP integer/,
            "Net::Works::Address->new_from_integer() died with $str_val as integer (v4)"
        );

        like(
            exception {
                Net::Works::Network->new_from_integer(
                    integer     => $bad_num,
                    mask_length => 20,
                    version     => 4,
                );
            },
            qr/\Q$str_val is not a valid IP integer/,
            "Net::Works::Network->new_from_integer() died with $str_val as integer (v4)"
        );
    }
}

{
    for my $bad_num ( undef, qw( -1 1.1 a-string google.com ) ) {
        my $str_val = defined $bad_num ? $bad_num : 'undef';

        like(
            exception {
                Net::Works::Address->new_from_integer(
                    integer => $bad_num,
                    version => 6,
                );
            },
            qr/\Q$str_val is not a valid IP integer/,
            "Net::Works::Address->new_from_integer() died with $str_val as integer (v6)"
        );

        like(
            exception {
                Net::Works::Network->new_from_integer(
                    integer     => $bad_num,
                    mask_length => 20,
                    version     => 6,
                );
            },
            qr/\Q$str_val is not a valid IP integer/,
            "Net::Works::Network->new_from_integer() died with $str_val as integer (v6)"
        );
    }
}

{
    for my $bad_str (
        undef,
        qw( -1 1.1 a-string google.com 1.2.3.555 a.3.4.5 ),
        ) {

        my $str_val = defined $bad_str ? $bad_str : 'undef';

        like(
            exception {
                Net::Works::Address->new_from_string(
                    string  => $bad_str,
                    version => 4,
                );
            },
            qr/\Q$str_val is not a valid IPv4 address/,
            "Net::Works::Address->new_from_string() died with $str_val as string (v4)"
        );

        $str_val = "$bad_str/20" if defined $bad_str;
        like(
            exception {
                Net::Works::Network->new_from_string(
                    string => ( defined $bad_str ? "$bad_str/20" : $bad_str ),
                    version => 4,
                );
            },
            qr/\Q$str_val is not a valid IP network/,
            "Net::Works::Network->new_from_string() died with $str_val as string (v4)"
        );
    }
}

{
    for my $bad_str (
        undef,
        qw( -1 1.1 a-string google.com 1.2.3.555 a.3.4.5 fffff:: abcd::1234::4321 g123::1234 ),
        ) {

        my $str_val = defined $bad_str ? $bad_str : 'undef';

        like(
            exception {
                Net::Works::Address->new_from_string(
                    string  => $bad_str,
                    version => 6,
                );
            },
            qr/\Q$str_val is not a valid IPv6 address/,
            "Net::Works::Address->new_from_string() died with $str_val as string (v4)"
        );

        $str_val = "$bad_str/20" if defined $bad_str;
        like(
            exception {
                Net::Works::Network->new_from_string(
                    string => ( defined $bad_str ? "$bad_str/20" : $bad_str ),
                    version => 6,
                );
            },
            qr/\Q$str_val is not a valid IP network/,
            "Net::Works::Network->new_from_string() died with $str_val as string (v4)"
        );
    }
}

{
    for my $bad (qw( 1.1.1.1/-1 1.1.1.1/33 )) {
        like(
            exception {
                Net::Works::Network->new_from_string(
                    string  => $bad,
                    version => 4,
                );
            },
            qr/\Qis not a valid IP mask length/,
            "Net::Works::Address->new_from_string() died with bad mask (v4)"
        );
    }

    for my $bad (qw( ::1/-1 ::1/129 )) {
        like(
            exception {
                Net::Works::Network->new_from_string(
                    string  => $bad,
                    version => 6,
                );
            },
            qr/\Qis not a valid IP mask length/,
            "Net::Works::Address->new_from_string() died with bad mask (v6)"
        );
    }
}
done_testing();
