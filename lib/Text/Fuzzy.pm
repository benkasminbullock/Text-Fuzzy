package Text::Fuzzy;
require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

@EXPORT_OK = qw/fuzzy_index/;
%EXPORT_TAGS = (
    all => \@EXPORT_OK,
);

use warnings;
use strict;
our $VERSION = "0.10_05";

__PACKAGE__->bootstrap ($VERSION);

# The following routine exports the C routines for the benefit of
# "CPAN::Nearest".

sub dl_load_flags
{
    return 0x01;
}

# This is a Perl-based edit distance routine which also returns the
# edit steps necessary to convert one string into the other. $distance
# is a boolean. If true it switches on

my $verbose = undef;

sub distance_edits
{
    return fuzzy_index (@_, 1);
}

sub fuzzy_index
{
    my ($needle, $haystack, $distance) = @_;
    # Test whether the inputs make any sense here.

    my $m = length ($needle);
    my $n = length ($haystack);
    my $longer;
    if ($distance) {
	$longer = $m > $n ? $m : $n;
    }
    my @haystack = split '', $haystack;
    my @needle   = split '', $needle;
    print "     ", join ("  ",@haystack), "\n" if $verbose;
    my @row1;
    print "  ", join ("  ",@row1), "\n" if $verbose;
    my @row2;
    my @way;
    if ($distance) {
	for (0..$n) {
	    $way[0][$_] = "i" x $_;
	}
	@row1 = map {$_} (0..$n);
    }
    else {
	@row1 = (0) x ($n + 1);
	for (0..$n) {
	    $way[0][$_] = '';
	}
    }
    for (0..$m) {
	$way[$_][0] = "d" x $_;
    }
    for my $i (1..$m) {
	$row2[0] = $i;
	print "[", $needle[$i - 1], "] " if $verbose;
	print $row2[0],"  " if $verbose;
	for my $j (1..$n) {
	    my $cost = ($needle[$i-1] ne $haystack[$j-1]);
	    my $deletion = $row1[$j] + 1;
	    my $insertion  = $row2[$j-1] + 1;
	    my $substitution = $row1[$j-1] + $cost;
	    my $min;
	    my $way;
	    $min = $deletion;
	    $way = 'd';
	    if ($min > $insertion) {
		$min = $insertion;
		$way = 'i';
	    }
	    if ($min > $substitution) {
		if ($cost) {
		    $way = 'r';
		}
		else {
		    $way = 'k';
		}
		$min = $substitution;
	    }
	    if ($way eq 'd') {
		$way[$i][$j] = ($way[$i-1][$j] ? $way[$i-1][$j]:'') . $way;
	    }
	    elsif ($way eq 'i') {
		$way[$i][$j] = ($way[$i][$j-1] ? $way[$i][$j-1]:'') . $way;
	    }
	    elsif ($way =~ /[kr]/) {
		$way[$i][$j] = ($way[$i-1][$j-1] ? $way[$i-1][$j-1]:'') . $way;
	    }
	    else {
		exit;
	    }
	    $row2[$j] = $min;
	    print $row2[$j],$way[$i][$j]," " if $verbose;
	}
	@row1 = @row2;
 	print "\n" if $verbose;
    }
    return ($row1[$n], $way[$m][$n]);
}


1;
