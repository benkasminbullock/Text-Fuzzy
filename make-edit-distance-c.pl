#!/home/ben/software/install/bin/perl

# This makes all the different edit distance C files from a master
# template.

use warnings;
use strict;
use Template;
use FindBin '$Bin';
use File::Compare;
use C::Utility qw/linein lineout/; 
use Deploy 'do_system';
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
my @cfiles;
for my $type (qw/char int/) {
    $vars{type} = "unsigned $type";
    $vars{function} = "distance_$type";
    $vars{ed_type} = "$type";
    $vars{stem} = "$type";
    my $notf = '';
    my $base = "$file-$vars{stem}";
    # This is the macro used in the .h file as a double-inclusion
    # guard.
    my $wrapper = "$base-h";
    $wrapper =~ s/-/_/g;
    $wrapper = uc $wrapper;
    $vars{wrapper} = $wrapper;
    # Temporarily, don't even build the trans versions
    my $cfile = "$base.c";
    do_file ($tt, "$file.c.tmpl", \%vars, $cfile);
    push @cfiles, $cfile;
    $vars{function} .= "_trans";
    $vars{stem} .= "-trans";
    my $tcfile = "ed-trans-$type.c";
    do_file ($tt, "ed-trans.c.tmpl", \%vars, $tcfile);
    push @cfiles, $tcfile;
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

for my $cfile (@cfiles) {
    do_system ("cfunctions $cfile");
}
exit;

sub do_file
{
    my ($tt, $infile, $vars, $outfile) = @_;
    if (-f $outfile) {
	chmod 0777, $outfile;
	unlink $outfile;
    }
    my $text = linein ($infile);
    $tt->process (\$text, $vars, \my $textout)
        or die '' . $tt->error ();
    lineout ($textout, $outfile);
    chmod 0444, $outfile;
}
