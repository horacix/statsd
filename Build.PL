use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::StatsD',
    license             => 'artistic',
    dist_author         => q{Horacio Gonzalez <horacio.gonzalez@lan.com>},
    dist_version_from   => 'lib/Net/StatsD.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Net-StatsD-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
