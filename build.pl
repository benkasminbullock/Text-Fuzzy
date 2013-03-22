#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use File::Copy;
eval {
    require Perl::Build;
};
if (! $@) {
    Perl::Build::perl_build (
	pre => './make-edit-distance-c.pl',
	pod => [
	    'lib/Text/Fuzzy.pod',
	],
	cmaker => [
	    'text-fuzzy',
	],
	no_cmaker_clean => 1,
	clean => './cleanup.pl',
    );
}
else {
    system_or_die ("./make-edit-distance-c.pl");
    copy 'lib/Text/Fuzzy.pod.tmpl', 'lib/Text/Fuzzy.pod';
    system_or_die ("perl Makefile.PL;make;make test");
}
exit;

sub system_or_die
{
    my ($command) = @_;
    my $r = system ($command);
    if ($r) {
	die $r;
    }
}
