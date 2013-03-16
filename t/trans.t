use warnings;
use strict;
use Test::More;
use Text::Fuzzy;
use utf8;
my $thing = Text::Fuzzy->new ('abc');
eval {
    $thing->set_trans (1);
    $thing->set_trans (0);
};
ok (! $@, "No errors turning transpositions on and off");

$thing->set_trans (0);
is ($thing->distance ('bac'), 2, "correct distance without transpos");

$thing->set_trans (1);
is ($thing->distance ('bac'), 1, "correct distance with transpos");

# Test using Unicode characters. The following string is set up to
# have an edit distance of 2 using transposition edit distance, but 4
# using the Levenshtein edit distance.

my $thing2 = Text::Fuzzy->new ('あいうかきえおくけこ');

$thing2->set_trans (0);
is ($thing2->distance ('あういかきおえくけこ'), 4, "correct distance without transpos");
$thing2->set_trans (1);
is ($thing2->distance ('あういかきおえくけこ'), 2, "correct distance with transpos");

done_testing ();
