#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Perl::Build;
perl_build (
    pre => './make-edit-distance-c.pl',
    pod => [
        'lib/Text/Fuzzy.pod',
    ],
    cmaker => [
        'text-fuzzy',
    ],
);
exit;
