#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Text::Fuzzy;

my @words = qw/bibbity bobbity boo/;
for my $word (@words) {
    my $tf = Text::Fuzzy->new ($word);
    $tf->no_exact (0);
    my $nearest1 = $tf->nearest (\@words);
    print "With exact, nearest to $word is $words[$nearest1]\n";
    # Make "$word" not match itself.
    $tf->no_exact (1);
    my $nearest2 = $tf->nearest (\@words);
    print "Without exact, nearest to $word is $words[$nearest2]\n";
}
