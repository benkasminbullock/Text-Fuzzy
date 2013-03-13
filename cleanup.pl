#!/home/ben/software/install/bin/perl
use warnings;
use strict;
my @types = qw/char int short/;
my @suffixes = qw/c h/;
my @files;
for my $type (@types) {
    for my $suffix (@suffixes) {
        my $file = "edit-distance-$type.$suffix";
	push @files, $file;
    }
}

for my $suffix (qw/log dvi/) {
    push @files, "algorithm.$suffix";
}

for my $file (@files) {
    if (-f $file) {
	unlink $file;
    }
}
