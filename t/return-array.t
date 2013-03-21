#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Test::More;
use Text::Fuzzy;

my @words = qw/
nice
rice
mice
lice
/;

my $tf = Text::Fuzzy->new ('dice');
my $nearest = $tf->nearest (\@words);

print "$nearest\n";

ok ($nearest >= 0);
$tf->set_max_distance (1);
$nearest = $tf->nearest (\@words);
cmp_ok ($nearest, '>=', 0, "Find word when maximum distance = distance");

my @nearest = $tf->nearest (\@words);

is (scalar @nearest, 4);

print "@nearest\n";

my @funky_words = qw/
nice
funky
rice
gibbon
lice
graham
garden
/;

@nearest = $tf->nearest (\@funky_words);
is_deeply (\@nearest, [0, 2, 4], "Picked out nearest words only");

done_testing ();
