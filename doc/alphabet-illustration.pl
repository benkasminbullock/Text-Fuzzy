#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Cairo;
#use Text::Fuzzy;

my $word1 = 'dandy';
my $word2 = 'monty';

# Number of cells

my $xcells = 5;
my $ycells = 5;

# Size of one cell

my $xsize = 30;
my $ysize = 45;

# Start position

my $xstart = 10;
my $ystart = 10;

# Get Cairo object

my $surface = Cairo::ImageSurface->create ('argb32', 700, 700);
my $cr = Cairo::Context->create ($surface);


for my $word ($word1, $word2, 'frognosealian') {

$cr->rectangle ($xstart, $ystart, $xcells * $xsize, $ycells * $ysize);
$cr->set_source_rgb (0, 0.7, 0.7);
$cr->fill;
my @letters = split //, $word;
my %filled;
for (@letters) {
    $filled{$_} = 1;
}
my @filled = map {ord ($_) - ord ('a') } sort keys %filled;
print "@filled\n";
#exit;
$cr->set_source_rgb (1, 1, 1);

for my $cell (@filled) {
    my $y = int ($cell / $xcells);
    my $x = int ($cell % $xcells);
    $cr->rectangle (
	$xstart + $x * $xsize,
	$ystart + $y * $ysize,
	$xsize,
	$ysize,
    );
    $cr->fill ();
}

$cr->set_source_rgb (1, 0.5, 0);
$cr->set_line_width ($xsize / 40);

for my $x (0..$xcells) {
    $cr->move_to ($xstart + $x * $xsize, $ystart);
    $cr->line_to ($xstart + $x * $xsize, $ystart + $ycells * $ysize);
    $cr->stroke ();
}
for my $y (0..$ycells) {
    $cr->move_to ($xstart, $ystart + $y * $ysize);
    $cr->line_to ($xstart + $xcells * $xsize, $ystart + $y * $ysize);
    $cr->stroke ();
}

$cr->set_source_rgba (0, 0, 0, 0.7);
$cr->set_font_size ($xsize * 4 / 5);
for (0..24) {
    my $x = $_ % $xcells;
    my $y = int ($_ / $xcells);
    my $c = chr (ord ('a') + $_);
    my $e = $cr->text_extents ($c);
    my $ydiff = $e->{height} + $e->{y_bearing};

    # The following insanity was discovered by trial and error.

    $cr->move_to ($xstart + ($x + 0.5) * $xsize - $e->{width} / 2 - $e->{x_bearing},
		  $ystart + ($y + 0.75) * $ysize);
    $cr->show_text ($c);
}
$xstart += 200;


}
$surface->write_to_png ('output.png');
