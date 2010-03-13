#!/usr/bin/perl

use strict;
use lib::POE::Component::Schedule;

my $version = $POE::Component::Schedule::VERSION;
my $tag = "release-$version";
print "Making tag '$tag'...\n";


my ($repo, $revision);

$ENV{LANG} = 'C';
open(my $svn_info, 'svn info|')
    or die "Can't run 'svn info: $!'";

while (<$svn_info>) {
    chomp;
    /^Repository Root: (.*)$/ and $repo = $1;
    /^Revision: (\d+)/ and $revision = $1;
}
close $svn_info;
die "'Repository Root' or 'Revision' not found in 'svn info' output " unless $repo && $revision;

# TODO Check if the tag already exists

my $cmd = qq|svn copy $repo/trunk $repo/tags/$tag -m "CPAN release $version from r$revision."|;

print "$cmd\nDo it? ";
my $response = <STDIN>;
chomp $response;
$response =~ /^(?:y(?:es)?|o(?:ui)?)$/ or exit 1;

exit system $cmd;
