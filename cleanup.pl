#!/home/ben/software/install/bin/perl
use warnings;
use strict;
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
    push @files, "algorithm.$suffix";
}

for my $file (@files) {
    if (-f $file) {
	unlink $file;
    }
}
