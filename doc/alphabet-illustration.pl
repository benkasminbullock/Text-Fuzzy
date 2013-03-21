#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Cairo;
#use Text::Fuzzy;

my $word1 = 'dandy';
my $word2 = 'monty';

# Number of cells

my $xcells = 6;
my $ycells = 5;

# Size of one cell

my $xsize = 80;
my $ysize = 80;

# Start position

my $xstart = 10;
my $ystart = 10;

# Get Cairo object

my $surface = Cairo::ImageSurface->create ('argb32', 700, 700);
my $cr = Cairo::Context->create ($surface);

$cr->rectangle ($xstart, $ystart, $xcells * $xsize, $ycells * $ysize);
$cr->set_source_rgb (0, 0.5, 0.5);
$cr->fill;

my @filled = (3, 6, 8, 10, 11, 24);

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
$cr->set_line_width (4);

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
for (0..25) {
    my $x = $_ % $xcells;
    my $y = int ($_ / $xcells);
    my $c = chr (ord ('a') + $_);
    my $e = $cr->text_extents ($c);
    my $ydiff = $e->{height} + $e->{y_bearing};

    # The following insanity was discovered by trial and error.

    $cr->move_to ($xstart + ($x + 0.5) * $xsize - $e->{width} / 2 - $e->{x_bearing},
		  $ystart + ($y + 0.7) * $ysize - $e->{height} /2 - $e->{y_bearing}/2 + $ydiff /2 );
    print "$c $ydiff ";
    for my $k (keys %$e) {
	print  "$k:$e->{$k} ";
    }
    print "\n";
    $cr->show_text ($c);
}

$cr->show_page;

$surface->write_to_png ('output.png');

# Draw background

# Draw cells

# Draw inactive cells

# Draw active cells

# Draw letters

