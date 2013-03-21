#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Perl::Build;
perl_build (
    pre => './make-edit-distance-c.pl',
    make_pod => './doc/make-pod.pl',
    cmaker => [
        'text-fuzzy',
    ],
    clean => './cleanup.pl',
);
exit;
