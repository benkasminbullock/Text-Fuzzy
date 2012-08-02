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
$vars{insert_cost} = 1;
$vars{delete_cost} = 1;
$vars{substitute_cost} = 1;
$vars{use_text_fuzzy} = 1;
for my $type (qw/char int/) {
    $vars{type} = "unsigned $type";
    $vars{function} = "distance_$type";
    $vars{ed_type} = "$type";
    my $outfile = "$file-$type.c";
    if (-f $outfile) {
        chmod 0777, $outfile;
        unlink $outfile;
    }
    $tt->process ("$file.c.tmpl", \%vars, $outfile)
        or die '' . $tt->error ();
    do_system ("cfunctions -inc $outfile");
    chmod 0444, $outfile;
}
