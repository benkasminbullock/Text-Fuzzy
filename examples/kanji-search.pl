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
my @kanji;
while (<$in>) {
    my $kanji;
    if (/^(\p{InCJKUnifiedIdeographs}+)/) {
	$kanji = $1;
    }
    if ($kanji) {
	push @kanji, $kanji;
    }
}
printf "Starting fuzzy searches over %d lines.\n", scalar @kanji;
search ('幾何学校');
search ('阿部総理大臣');
search ('何校');
exit;

sub search
{
    my ($silly) = @_;
    my $start = time ();
    my $search = Text::Fuzzy->new ($silly);
#    $search->set_max_distance (3);
    my $n = $search->nearest (\@kanji);
    if ($n >= 0) {
	printf "$silly nearest is $kanji[$n] (distance %d)\n",
	    $search->last_distance ();
    }
    else {
	printf "Nothing like '$silly' was found within the edit distance %d.\n",
	    $search->get_max_distance ();
    }
    my $end = time ();
    printf "Fuzzy search took %g seconds.\n", ($end - $start);
}

