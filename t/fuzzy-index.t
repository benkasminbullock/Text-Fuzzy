use warnings;
use strict;
use Test::More;
use Text::Fuzzy 'fuzzy_index';

my ($distance, $edits) = fuzzy_index ('dog', 'dawg', 1);

is ($distance, 2);
ok ($edits eq 'krik' || $edits eq 'kirk' # Oh but it's true As we went
                                         # warp factor two And I met
                                         # all of the crew Where's
                                         # Captain Kirk?
);

print "$edits\n";
done_testing ();
exit;

# Where's Spock?
