#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Template;
use FindBin '$Bin';
use File::Compare;

my $tt = Template->new (
    ABSOLUTE => 1,
    INCLUDE_PATH => [
        $Bin,
    ],
);
my $file = 'edit-distance';

my %vars;
$vars{compare_c1_c2} = 'c1 == c2';
$vars{insert_cost} = 1;
$vars{delete_cost} = 1;
$vars{substitute_cost} = 1;
$vars{use_text_fuzzy} = 1;
for my $trans (0, 1) {
    $vars{trans} = $trans;
    for my $type (qw/char int/) {
	$vars{type} = "unsigned $type";
	$vars{function} = "distance_$type";
	$vars{ed_type} = "$type";
	$vars{stem} = "$type";
	if ($trans) {
	    $vars{function} .= "_trans";
	    $vars{stem} .= "-trans";
	}
	my $base = "$file-$vars{stem}";
	# This is the macro used in the .h file as a double-inclusion
	# guard.
	my $wrapper = "$base-h";
	$wrapper =~ s/-/_/g;
	$wrapper = uc $wrapper;
	$vars{wrapper} = $wrapper;
	my $cfile = "$base.c";
	do_file ($tt, "$file.c.tmpl", \%vars, $cfile);
	my $hfile = "$base.h";
	do_file ($tt, "$file.h.tmpl", \%vars, $hfile);
    }
}

# Write "config.h" from "config".

open my $config, "<", "$Bin/config" or die $!;
my %config;
while (<$config>) {
    if (/^\s*#/ || /^\s*$/) {
	next;
    }
    if (! /([A-Z_]+)\s+(.*)/) {
	die "$.: Bad line $_";
    }
    my ($key, $value) = ($1, $2);
    $config{$key} = $value;
}

close $config or die $!;

open my $cfgh, ">", "$Bin/config.h" or die $!;
my $w = 'TEXT_FUZZY_CONFIG';
print $cfgh <<EOF;
#ifndef $w
#define $w
EOF
for my $key (sort keys %config) {
    print $cfgh "#define $key $config{$key}\n";
}
print $cfgh <<EOF;
#endif /* ndef $w */
EOF
close $cfgh or die $!;

exit;

sub do_file
{
    my ($tt, $infile, $vars, $outfile) = @_;
    if (-f $outfile) {
	chmod 0777, $outfile;
	unlink $outfile;
    }
    # Add line directives.
    open my $in, "<", $infile or die $!;
    my $text = '';
    while (<$in>) {
	my $n = $. + 1;
	s/#line(\s*)$/#line $n "$infile"$1/;
	$text .= $_;
    }
    close $in or die $!;
    $tt->process (\$text, $vars, $outfile)
        or die '' . $tt->error ();
    chmod 0444, $outfile;
}
