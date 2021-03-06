use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Test::More;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";
use Text::Fuzzy;
my $tf = Text::Fuzzy->new ("fu");
my $guff = "fü";
my $guffcopy = $guff;
$tf->distance ($guffcopy);
ok ($guff eq $guffcopy);
done_testing ();
