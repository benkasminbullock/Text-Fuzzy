#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Text::Fuzzy;

# The directory of files served by the web server.

my $web_root = '/usr/local/www/data';

# If the query is something like
# "http://www.sljfaq.org/afaq/infults.html", the value of $path_info
# is "afaq/infults.html".

my $path_info = $ENV{REQUEST_URI};

if (! defined $path_info) {
    fail ("No path info");
}

if ($0 =~ /$path_info/) {
    fail ("Don't redirect to self");
}

# This is the list of files under the main page.

my @allfiles = get_all_files ($web_root, '');

# This is our spelling search engine.

my $tf = Text::Fuzzy->new ($path_info);

my $nearest = $tf->nearest (\@allfiles);

if (defined $nearest) {
    redirect ($allfiles[$nearest]);
}
else {
    fail ("Nothing like $path_info was found");
}
exit;

sub get_all_files
{
    my ($root, $dir) = @_;
    my @allfiles;
    my $full_dir = "$root/$dir";
    if (! -d $full_dir) {
        fail ("$full_dir is not a directory");
    }
    opendir DIR, $full_dir or fail ("Can't open directory $full_dir: $!");
    my @files = grep !/^\./, readdir DIR;
    closedir DIR or fail ("Can't close $full_dir: $!");
    for my $file (@files) {
        my $dir_file = "$dir/$file";
        my $full_file = "$root/$dir_file";
        if (-d $full_file) {
            push @allfiles, get_all_files ($root, $dir_file);
        }
        else {
            push @allfiles, $dir_file;
        }
    }
    return @allfiles;
}

sub redirect
{
    my ($url) = @_;
    print <<EOF;
Status: 301
Location: $url

EOF
    exit;
}

sub fail
{
    my ($error) = @_;
    my $time = scalar gmtime ();
    print <<EOF;
Content-Type: text/plain

$error
EOF
    print STDERR "$0: $time: $error\n";
    exit;
}
