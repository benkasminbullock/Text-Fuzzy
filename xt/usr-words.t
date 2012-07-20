#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use File::Slurp;
use Text::Fuzzy;
my $file = '/usr/share/dict/words';
my $word;
if (@ARGV) {
    $word = $ARGV[0];
}
else {
    $word = 'bingos';
}
my $tf = Text::Fuzzy->new ($word);
my $nearest = $tf->scan_file ($file);
if ($nearest) {
    print "Nearest to $word is $nearest.\n";
}
else {
    print "Nothing similar in $file.\n";
}
