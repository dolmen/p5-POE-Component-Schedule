#!/usr/bin/env perl
use utf8;  # vim:set ts=4 sw=4:

use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'POE::Component::Schedule',
    dist_author         => 'Olivier Mengué <dolmen@cpan.org>',
    license             => 'perl',
    meta_add            => {
        resources => {
            homepage => 'http://code.google.com/p/poe-component-schedule/',
            repository => 'http://poe-component-schedule.googlecode.com/svn/trunk/',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=POE-Component-Schedule',
        },
    },
    requires            => {
		# PoCoSchedule is known to work on 1.006
		# But requiring lastest should fix most problems.
		# And we don't have anymore the constraint that the last POE available
		# on ActivePerl was 1.006.
        'POE' => '1.284',
        'DateTime' => 0,
        'DateTime::Set' => '0.25',
        'DateTime::TimeZone' => '1.10',
        # HP-UX requires a plugin for local TZ detection
        ($^O eq 'hpux' ? ('DateTime::TimeZone::HPUX' => '1.04') : () ),
    },
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'cover_db' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
