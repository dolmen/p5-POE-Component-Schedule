#!/usr/bin/perl

use utf8;
use v5.10.0;
use strict;


open my $Changes, "<:utf8", "Changes";

my $dist = 'POE-Component-Schedule';
my $desc = <$Changes>;
chomp $desc;

my @releases;

while (<$Changes>) {
    chomp;
    next if /^$/;

    if (m/^(?<version>\d+\.\d+(_\d+)?)\s+(?<date>\d{4}-\d{2}-\d{2})(?:T(?<time>\d{2}:\d{2}) ?(?<tz>Z|[+-]\d{2}:\d{2})?)? +(?<author_id>\w+) \((?<author_name>[^)]+)\)/) {
	push @releases, {
	    %+,
	    changes => [],
	};
    } elsif (m/^(?: {8}|\t)  \s*(\S.*)$/) {
	$releases[$#releases]{changes}[-1] .= " $1";
    } elsif (m/^(?: {8}|\t)(\S.*)$/) {
	push @{$releases[$#releases]{changes}}, $1;
    } else {
	print STDERR "Error line $.: $_\n";
    }
}
close $Changes;

use YAML 0.71 ();
YAML::DumpFile("Changes.yml", \@releases);

use XML::RSS;
use DateTime;
use DateTime::Format::W3CDTF;

my $rss = XML::RSS->new(version => '1.0');
$rss->channel(
    title => "$dist releases",
    description => $desc,
    (map { $_ => "http://search.cpan.org/dist/POE-Component-Schedule/" } qw/about link/),
    dc => {
	date => DateTime::Format::W3CDTF->new->format_datetime(DateTime->now(time_zone => 'local')),
	creator => "$releases[0]{author_name} <".lc($releases[0]{author_id}).'@cpan.org>',
	language => 'en-us',
    },
    syn => {
	updatePeriod => 'daily',
    },
    taxo => [
	'http://dmoz.org/Computers/Programming/Languages/Perl/'
    ],
);

for my $r (@releases) {
    my $link = 'http://search.cpan.org/~'.lc($r->{author_id})."/$dist-$r->{version}/";
    $rss->add_item(
	title => "$dist $r->{version}",
	about => $link,
	link => $link,
	description => "<ul>\n".join('', map {"<li>$_</li>\n"} @{$r->{changes}}).'</ul>',
	dc => {
	    creator => "$r->{author_name} <".lc($r->{author_id}).'@cpan.org>',
	    date => "$r->{date}T$r->{time}$r->{tz}",
	}
    );
}

open my $Changes_rss, '>:utf8', "Changes.rss";
print $Changes_rss $rss->as_string;
close $Changes_rss;
