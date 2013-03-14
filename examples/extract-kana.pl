#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Lingua::JA::Moji ':all';
use Text::Fuzzy;
use Time::HiRes 'time';
use utf8;
binmode STDOUT, ":utf8";
my $infile = '/home/ben/data/edrdg/edict';
open my $in, "<:encoding(EUC-JP)", $infile or die $!;
my @kana;
while (<$in>) {
    my $kana;
    if (/\[(\p{InKana}+)\]/) {
	$kana = $1;
    }
    elsif (/^(\p{InKana}+)/) {
	$kana = $1;
    }
    else {
#	print "$infile:$.: no kana in $_.\n";
    }
    if ($kana) {
	$kana = kana2katakana ($kana);
	push @kana, $kana;
    }
}
printf "Starting fuzzy searches over %d lines.\n", scalar @kana;
search ('ウオソウコ');
search ('アイウエオカキクケコバビブベボハヒフヘホ');
search ('アルベルトアインシュタイン');
exit;

sub search
{
    my ($silly) = @_;
    my $start = time ();
    my $search = Text::Fuzzy->new ($silly);
    my $n = $search->nearest (\@kana);
    if ($n >= 0) {
	printf "$silly nearest is $kana[$n] (distance %d)\n",
	    $search->last_distance ();
    }
    else {
	printf "Nothing like '$silly' was found within the edit distance %d.\n",
	    $search->get_max_distance ();
    }
    my $end = time ();
    printf "Fuzzy search took %g seconds.\n", ($end - $start);
}

