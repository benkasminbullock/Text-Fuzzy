use warnings;
use strict;
use Test::More;
use Text::Fuzzy;
my $thing = Text::Fuzzy->new ('abc');
eval {
    $thing->set_trans (1);
    $thing->set_trans (0);
};
ok (! $@, "No errors turning transpositions on and off");

$thing->set_trans (0);
is ($thing->distance ('bac'), 2);

TODO: {
    local $TODO = 'this is not implemented yet';
    $thing->set_trans (1);
    is ($thing->distance ('bac'), 1);
};
    

done_testing ();
