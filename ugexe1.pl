#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Lingua::JA::Moji ':all';
use lib 'blib/lib';
use lib 'blib/arch';
use Text::Fuzzy;
use Text::Levenshtein::Damerau;
use Text::Levenshtein::Damerau::XS qw/xs_edistance/;
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
    if ($kana) {
	$kana = kana2katakana ($kana);
	push @kana, $kana;
    }
}

my $word = 'ウオソウコ';
my $tld = Text::Levenshtein::Damerau->new($word);
my $tz  = Text::Fuzzy               ->new($word);

print "Text::Levenshtein::Damerau\n";
print "Best match:\t"    . $tld->dld_best_match   ({ list => \@kana }) . "\n";
print "Best distance:\t" . $tld->dld_best_distance({ list => \@kana }) . "\n";

$tz->transpositions_ok (1);
print "\nText::Fuzzy (transpositions)\n";
print "Best match:\t"    . $kana[$tz->nearest(\@kana)] . "\n";
print "Best distance:\t" . $tz->last_distance          . "\n";

$tz->transpositions_ok (0);
print "\nText::Fuzzy (no transpositions)\n";
print "Best match:\t"    . $kana[$tz->nearest(\@kana)] . "\n";
print "Best distance:\t" . $tz->last_distance          . "\n";


my @n6 = nearest2($word,10,\@kana);
print "\nText::Levenshtein::Damerau::XS (nearest2, with max distance speedup)\n";
print "Best match:\t"    . $n6[1] . "\n";
print "Best distance:\t" . $n6[0] . "\n";


my @n7 = nearest3($word,10,\@kana);
print "\nText::Fuzzy->distance (nearest3, with max distance speedup)\n";
print "Best match:\t"    . $n7[1] . "\n";
print "Best distance:\t" . $n7[0] . "\n";


1;

# use imitate nearest3 with text::levenshtein::damerau::xs
sub nearest2 {
    my ($word,$max,$dict) = @_;
    my $x = 'ウオソウコ';

    # some large_value to imitate INT_MAX
    my $rolling_best = 999999;
    my $best_match;

    foreach my $check_word ( @{$dict} ) {
    	my $distance = xs_edistance($x,$check_word,$max);
    	#print $check_word . "|$distance\n";
        if(  $distance < $rolling_best && $distance >= 0 ) {
            $rolling_best = $distance;
            $best_match   = $check_word;
            $max = $distance;
        }
    }

    return ($rolling_best,$best_match);
}

# use imitate nearest3 with text::fuzzy->distance
sub nearest3 {
    my ($word,$max,$dict) = @_;
    my $tf = Text::Fuzzy->new('ウオソウコ');
    $tf->set_max_distance($max);
    $tf->transpositions_ok(1);

    # some large_value to imitate INT_MAX
    my $rolling_best = 999999;
    my $best_match;

    foreach my $check_word ( @{$dict} ) {
    	my $distance = $tf->distance($check_word);
    	#print $check_word . "|$distance\n";
        if(  $distance < $rolling_best && $distance >= 0 ) {
            $rolling_best = $distance;
            $best_match   = $check_word;
            $tf->set_max_distance($max);
        }
    }

    return ($rolling_best,$best_match);
}
