use Test::Base;
use Config::Any::YAML;
use Config::Multi;
use FindBin;
use File::Spec;
use File::Basename;
use utf8;
use Data::Dumper;

if ( !Config::Any::YAML->is_supported ) {
    plan skip_all => 'YAML format not supported';
}
else {
    plan tests => 1 * blocks;
}

my $dir = File::Spec->catfile( $FindBin::Bin , 'conf' );

run { 
    my $block = shift;
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
