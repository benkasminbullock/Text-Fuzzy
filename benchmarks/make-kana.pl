#!/home/ben/software/install/bin/perl
use warnings;
use strict;

# Lingua::JA::Moji is extremely slow, so make the kana list by itself.


use Lingua::JA::Moji ':all';
use FindBin;
my $max = 0;
my $infile = '/home/ben/data/edrdg/edict';

# Our list of characters.

my @kana;

open my $in, "<:encoding(EUC-JP)", $infile or die $!;
while (<$in>) {
    my $kana;
    if (/\[(\p{InKana}+)\]/) {
	$kana = $1;
    }
    elsif (/^(\p{InKana}+)/) {
	$kana = $1;
    }
    if ($kana) {
	$kana = kana2katakana ($kana);
	push @kana, $kana;
    }
}
close $in or die $!;

my $outfile = "$FindBin::Bin/kana.txt";
open my $out, ">:encoding(UTF-8)", $outfile or die $!;
for (@kana) {
    print $out "$_\n";
}
close $out or die $!;
