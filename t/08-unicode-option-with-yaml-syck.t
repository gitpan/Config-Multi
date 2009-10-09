use Test::Base;
use Config::Any::YAML;
use Config::Multi;
use FindBin;
use File::Spec;
use File::Basename;
use utf8;
use Data::Dumper;

sub is_supported_yaml_syck {
    eval { require YAML::Syck; YAML::Syck->VERSION( '0.70' ) };
    return $@ ? 0 : 1;
}

if ( is_supported_yaml_syck ) {
    plan tests => 1 * blocks;
}
else {
    plan skip_all => 'YAML::Syck not supported';
}

my $dir = File::Spec->catfile( $FindBin::Bin , 'conf' );

run { 
    my $block = shift;
    no warnings 'once';
    local $YAML::Syck::ImplicitUnicode = 1;
    my $cm = Config::Multi->new({dir => $dir, app_name => 'unicode', extension => 'yml', unicode => 1 });
    my $config = $cm->load();

    is_deeply( $block->expected, $config );
}

__END__
=== test
--- expected eval
{
    hoge => 'ほげ',
    foo  => {
        bar => 'ばー',
    },
    fuga => 'ふが',
}
