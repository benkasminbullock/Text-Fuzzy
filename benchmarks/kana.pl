#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Text::Fuzzy;
use Time::HiRes 'time';
use JSON;
use utf8;
binmode STDOUT, ":utf8";
use FindBin;
my $infile = "$FindBin::Bin/kana.txt";
open my $in, "<:encoding(UTF-8)", $infile or die $!;
my @kana;
while (<$in>) {
    chomp;
    push @kana, $_;
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
    print "$silly\n";
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
	print "Length rejections: ", $search->length_rejections (), "\n";
	print "Alphabet rejections: ", $search->ualphabet_rejections (), "\n";
	print "time: $result{time}\n";
	push @$tests, \%result;
    }
}

