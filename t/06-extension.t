use Test::Base;
use Config::Multi;
use FindBin;
use File::Spec;
use File::Basename;
use Data::Dumper;

plan tests => 1 * blocks ;

my $dir = File::Spec->catfile( $FindBin::Bin , 'conf' );

run {
    my $block = shift;
    my $extension = $block->name;
    my $cm = Config::Multi->new({
        dir       => $dir,
        app_name  => 'myapp',
        extension => $extension,
    });
    my $config = $cm->load();

    is( $block->boin, $config->{Boin} );
}

__END__
=== yaml
--- boin chomp
this extension is yaml

