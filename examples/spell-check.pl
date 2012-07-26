#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Text::Fuzzy;
use Lingua::EN::PluralToSingular 'to_singular';

my $dict = '/usr/share/dict/words';
GetOptions (
    "dict=s" => \$dict,
);
my @words;
my %words;
my $min_length = 4;
read_dictionary ($dict, \@words, \%words);
# Known mistakes, don't repeat.
my %known;
# Spell-check each file on the command line.
for my $file (@ARGV) {
    open my $input, "<", $file or die "Can't open $file: $!";
    while (<$input>) {
        my @line = split /[^a-z']+/i, $_;
        for my $word (@line) {
            my $clean_word = to_singular (lc $word);
            if ($words{$clean_word}) {
                # It is in the dictionary.
                next;
            }
            if (length $word < $min_length) {
                # Very short words are ignored.
                next;
            }
            if ($word eq uc $word) {
                # Acronym like BBC, IRA, etc.
                next;
            }
            if ($known{$clean_word}) {
                # This word was already given to the user.
                next;
            }
            my $tf = Text::Fuzzy->new ($clean_word);
            my $nearest = $tf->nearest (\@words);
            if (defined $nearest) {
                my $correction = $words[$nearest];
                print "$file:$.: '$word' may be $correction.\n";
                $known{$clean_word} = $correction;
            }
            else {
                print "$file:$.: $word may be a spelling mistake.\n";
                $known{$clean_word} = 1;
            }
        }
    }
    close $input or die $!;
}

exit;

sub read_dictionary
{
    my ($dict, $words_array, $words_hash) = @_;    
    open my $din, "<", $dict or die "Can't open dictionary $dict: $!";
    while (<$din>) {
        chomp;
        push @$words_array, lc $_;
        $words_hash->{$_} = 1;
    }
    close $din or die $!;
}
