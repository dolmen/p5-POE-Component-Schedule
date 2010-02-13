#!/usr/bin/perl

use strict;
use lib::POE::Component::Schedule;

my $tag = 'release-' . $POE::Component::Schedule::VERSION;
print "Making tag '$tag'...\n";


my $repo;

$ENV{LANG} = 'C';
open(my $svn_info, 'svn info|')
    or die "Can't run 'svn info: $!'";

while (<$svn_info>) {
    chomp;
    if (/^Repository Root: (.*)$/) {
	$repo = $1;
    }
}
close $svn_info;
die "'Repository Root' not found in 'svn info' output " unless $repo;

my $cmd = qq|svn copy $repo/trunk $repo/tags/$tag -m "Tagging '$tag'."|;
print "$cmd\n";
exit system $cmd;
