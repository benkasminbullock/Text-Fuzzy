use warnings;
use strict;
use utf8;
use Test::More;
binmode STDOUT, ":utf8";
use Text::Fuzzy;
my $agogo = 'アルベルトアインシュタイン';
my @words = qw/
ヒトアンシン
リヒテンシュタイン
ヒトアンシン
アイウエオカキクケコバビブベボハヒフヘホ
/;
my $tf = Text::Fuzzy->new ($agogo);
my $is = $tf->nearest (\@words);
if ($is >= 0) {
    printf "$words[$is] %d\n", $tf->last_distance ();
}
print $tf->distance ('リヒテンシュタイン'), "\n";
ok (1);
done_testing ();
