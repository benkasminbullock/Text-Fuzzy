#!/home/ben/software/install/bin/perl
use warnings;
use strict;
my @types = qw/char int/;
my @suffixes = qw/c h/;
for my $type (@types) {
    for my $suffix (@suffixes) {
        my $file = "edit-distance-$type.$suffix";
        if (-f $file) {
            unlink $file;
        }
    }
}


