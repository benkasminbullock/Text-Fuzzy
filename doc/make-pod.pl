#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Template;
use Perl::Build qw/get_info get_commit/;
use Perl::Build::Pod ':all';
BEGIN: {
    use FindBin '$Bin';
    use lib "$Bin/../lib";
};

my %pbv = (
    base => "$Bin/..",
#    verbose => 1,
);

my $info = get_info (%pbv);
my $commit = get_commit (%pbv);

# Names of the input and output files containing the documentation.

my $pod = 'Fuzzy.pod';
my $input = "$Bin/../lib/Text/$pod.tmpl";
my $output = "$Bin/../lib/Text/$pod";

open my $config, "<", "$Bin/../config" or die $!;
my %config;
while (<$config>) {
    if (/^\s*#/ || /^\s*$/) {
	next;
    }
    if (! /([A-Z_]+)\s+(.*)/) {
	die "$.: Bad line $_";
    }
    my ($key, $value) = ($1, $2);
    $config{$key} = $value;
}

close $config or die $!;

# Template toolkit variable holder

my %vars = (
    commit => $commit,
    info => $info,
);
$vars{config} = \%config;

my $tt = Template->new (
    ABSOLUTE => 1,
    INCLUDE_PATH => [
	$Bin,
	pbtmpl (),
	"$Bin/../examples",
    ],
    ENCODING => 'UTF8',
    FILTERS => {
        xtidy => [
            \& xtidy,
            0,
        ],
    },
    STRICT => 1,
);

$tt->process ($input, \%vars, $output, {binmode => 'utf8'})
    or die '' . $tt->error ();

exit;
