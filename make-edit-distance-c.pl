#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Template;
use FindBin;
use File::Compare;
use Deploy 'do_system';

my $tt = Template->new (
    ABSOLUTE => 1,
    INCLUDE_PATH => [
        $FindBin::Bin,
    ],
);
my $file = 'edit-distance';

my %vars;
$vars{compare_c1_c2} = 'c1 == c2';
for my $type (qw/char int/) {
    $vars{type} = $type;
    my $outfile = "$file-$type.c";
    $tt->process ("$file.c.tmpl", \%vars, $outfile)
        or die '' . $tt->error ();
    do_system ("cfunctions -inc $outfile");
}
