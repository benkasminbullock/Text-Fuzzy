#!/home/ben/software/install/bin/perl

# remove generated files

use warnings;
use strict;
use Deploy 'do_system';

my @types = qw/char int short/;
my @suffixes = qw/c h/;
my @files;
for my $trans (0, 1) {
    for my $type (@types) {
	for my $suffix (@suffixes) {
	    for my $tf ('', '-no-tf') {
		my $base = "edit-distance-$type";
		if ($trans) {
		    $base .= "-trans";
		}
		my $file = "$base$tf.$suffix";
		push @files, $file;
	    }
	}
    }
}

for my $suffix (qw/log dvi/) {
    push @files, "doc/algorithm.$suffix";
}

my $cfgh = "config.h";
push @files, $cfgh;

for my $file (@files) {
    if (-f $file) {
	unlink $file;
    }
}

do_system ("rm -rf Text-Fuzzy-0.*");
