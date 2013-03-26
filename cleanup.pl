#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Deploy 'do_system';

my @types = qw/char int short/;
my @suffixes = qw/c h/;
my @files;
for my $trans (0, 1) {
    for my $type (@types) {
	for my $suffix (@suffixes) {
	    my $base = "edit-distance-$type";
	    if ($trans) {
		$base .= "-trans";
	    }
	    my $file = "$base.$suffix";
	    push @files, $file;
	}
    }
}

for my $suffix (qw/log dvi/) {
    push @files, "doc/algorithm.$suffix";
}

for my $file (@files) {
    if (-f $file) {
	unlink $file;
    }
}
my $cfgh = "config.h";
if (-f $cfgh) {
unlink ($cfgh);
}

do_system ("rm -rf Text-Fuzzy-0.*");
