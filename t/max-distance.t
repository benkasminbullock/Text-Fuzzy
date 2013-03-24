# Test the maximum distance functions.

use warnings;
use strict;
use Text::Fuzzy;
use Test::More;

my $tf = Text::Fuzzy->new ('abcdefghijklm');
my $notmatch = 'nopqrstuvwxyz';

my $d = $tf->distance ($notmatch);
cmp_ok ($d, '>=', 10);

# Test switching off the distance completely.

$tf->set_max_distance ();
$d = $tf->distance ($notmatch);
is ($d, length ($notmatch));

# Test whether we found it in the list.

my @list = ($notmatch);
my $found = $tf->nearest (\@list);
is ($found, 0);
is ($tf->last_distance (), length ($notmatch));



done_testing ();
