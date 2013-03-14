#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Template;
use Table::Readable 'read_table';

my $outfile = 'algorithm.tex';
my $infile = "$outfile.in";
my $refs = 'refs.txt';

my @refs = read_table ($refs);

my %name2ref;
for (@refs) {
    $name2ref{$_->{name}} = $_;
}
my $text = '';
open my $in, "<:encoding(utf8)", $infile or die $!;
while (<$in>) {
    $text .= $_;
}
close $in or die;

while ($text =~ /\@ref\{(.*?)\}/g) {
    if ($name2ref{$1}) {
	print "Found $1\n";
    }
    else {
	print "Not found $1\n";
    }
}
