use strict;
use warnings;
use ExtUtils::MakeMaker;

my $pm = 'lib/Text/Fuzzy.pm';
my $pod = 'lib/Text/Fuzzy.pod';
my $repo = 'https://github.com/benkasminbullock/Text-Fuzzy';

WriteMakefile (
    NAME => 'Text::Fuzzy',
    VERSION_FROM => $pm,
    ABSTRACT_FROM => $pod,
    AUTHOR => 'Ben Bullock <bkb@cpan.org>',
    LICENSE => 'perl',
    PREREQ_PM => {
    },
    META_MERGE => {
        resources => {
            repository => $repo,
            bugtracker => "$repo/issues",
        },
    },
    #CCFLAGS => '-Wall -g',
    OBJECT => 'Fuzzy.o text-fuzzy.o edit-distance-char.o edit-distance-int.o',
);
