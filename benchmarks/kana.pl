#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Lingua::JA::Moji ':all';
use Text::Fuzzy;
use Time::HiRes 'time';
use JSON;
use utf8;
binmode STDOUT, ":utf8";
my $infile = '/home/ben/data/edrdg/edict';
open my $in, "<:encoding(EUC-JP)", $infile or die $!;
my @kana;
my $count = 0;
# In practice, "no_alphabet" only starts winning if we set $max < 30
# or so here, in which case it is not really winning anything since
# the times are so small anyway.
#my $max = 100;
my $max = 0;

while (<$in>) {
    if ($max) {
	$count++;
	if ($count > $max) {
	    last;
	}
    }
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
my %result;
$result{lines} = scalar @kana;
my @tests;
# Discard the first test, which comes out wrongly due to some kind of
# warming-up effect.
my @discard;
search (\@discard, 'ウオソウコ');
search (\@tests, 'ウオソウコ');
search (\@tests, 'アイウエオカキクケコバビブベボハヒフヘホ');
#search (\@tests, 'アイウエオカキクケコバビブベボハヒフヘホアイウエオカキクケコバビブベボハヒフヘホアイウエオカキクケコバビブベボハヒフヘホアイウエオカキクケコバビブベボハヒフヘホアイウエオカキクケコバビブベボハヒフヘホ');
search (\@tests, 'アルベルトアインシュタイン');
search (\@tests, 'バババブ');
search (\@tests, 'バババブアルベルト');
$result{tests} = \@tests;
#print to_json (\%result, {pretty => 1});
my %ratios;
for my $test (@tests) {
    my $input = $test->{input};
    if ($test->{no_alphabet}) {
	$ratios{$input}{no_alphabet} = $test->{time};
    }
    elsif (! $test->{no_alphabet}) {
	$ratios{$input}{alphabet} = $test->{time};
    }
}

for my $input (keys %ratios) {
    printf "%s:\nwith: %g without: %g ratio: %3.7g\n",
    $input,
    $ratios{$input}{alphabet},
    $ratios{$input}{no_alphabet},
    $ratios{$input}{alphabet} / $ratios{$input}{no_alphabet};
}
exit;

sub search
{
    my ($tests, $silly) = @_;
    for my $no_alphabet (0, 1) {
	my %result;
	$result{no_alphabet} = $no_alphabet ? JSON::true : JSON::false;
	$result{input} = $silly;
	my $search = Text::Fuzzy->new ($silly);
#	$search->no_alphabet ($no_alphabet);
	$search->transpositions_ok ($no_alphabet);
	my $start = time ();
	my $n = $search->nearest (\@kana);
	$result{nearest} = $n;
	$result{max_distance} = $search->get_max_distance ();
	if ($n >= 0) {
	    $result{best_match} = $kana[$n];
	    $result{distance} = $search->last_distance ();
	    $result{found} = JSON::true;
	}
	else {
	    $result{found} = JSON::false;
	}
	my $end = time ();
	$result{time} = $end - $start;
	push @$tests, \%result;
    }
}

