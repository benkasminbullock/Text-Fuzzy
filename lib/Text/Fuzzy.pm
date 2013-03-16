package Text::Fuzzy;
require Exporter;
require DynaLoader;
@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = qw//;
use warnings;
use strict;
our $VERSION = "0.10_02";
__PACKAGE__->bootstrap ($VERSION);

sub dl_load_flags
{
    return 0x01;
}

1;
