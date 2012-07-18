#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use File::Slurp;
use Text::Fuzzy;
my $file = '/usr/share/dict/words';
my @words = read_file ($file, chomp => 1);
my $word;
if (@ARGV) {
    $word = $ARGV[0];
}
else {
    $word = 'bingos';
}
my $tf = Text::Fuzzy->new ($word);
my $nearest = $tf->nearest (\@words);
if ($nearest >= 0) {
    print "Nearest to $word is $words[$nearest].\n";
}
else {
    print "Nothing similar in $file.\n";
}
