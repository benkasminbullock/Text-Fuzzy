#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Template;
use Table::Readable 'read_table';
use Deploy 'do_system';
use File::Copy;

my $outfile = 'algorithm.tex';
my $infile = "$outfile.in";
my $refs = 'refs.txt';

my @refs = read_table ($refs);

my %name2ref;
for (@refs) {
    $name2ref{$_->{name}} = $_;
}
my $text = '';
open my $in, "<:encoding(utf8)", $infile or die $!;
while (<$in>) {
    $text .= $_;
}
close $in or die;

while ($text =~ /\@ref\{(.*?)\}/g) {
    if ($name2ref{$1}) {
#	print "Found $1\n";
    }
    else {
	print "Not found $1\n";
    }
}

my $ref_tex = <<'EOF';
\begin{thebibliography}{1}
EOF

for (@refs) {
    $ref_tex .= "\\bibitem{$_->{name}} ";
    if ($_->{author1}) {
	$ref_tex .= <<EOF;
$_->{author1} {\\em $_->{title}} $_->{date}
EOF
    }
    else {
	$ref_tex .= "\n";
    }
}

$ref_tex .= <<'EOF';
\end{thebibliography}
EOF

print $ref_tex;
#exit;

$text =~ s/\@references/$ref_tex/;

open my $out, ">:encoding(utf8)", $outfile or die $!;
print $out $text;
close $out or die $!;
#> /dev/null 2> /dev/null
do_system ("pdflatex $outfile ");
my $pdf = "algorithm.pdf";
if (! -f $pdf) {
    die;
}
copy $pdf, "/home/ben/$pdf" or die $!;
