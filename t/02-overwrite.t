use Test::Base;
use Config::Multi;
use FindBin;
use File::Spec;
use File::Basename;
use Data::Dumper;

plan tests => 3 * blocks ;

my $dir = File::Spec->catfile( $FindBin::Bin , 'conf' );

run { 
    my $block = shift;
    my $cm = Config::Multi->new({dir => $dir , app_name => 'myapp' , prefix => $block->prefix , extension => 'yml' });
    my $config = $cm->load();

    is( $block->love, $config->{love} );
    is( $block->animal, $config->{animal} );
    is( $block->boin, $config->{boin} );
}

__END__
=== prefix foo
--- prefix chomp
foo
--- love chomp
cat
--- animal chomp
shark
--- boin chomp
shark
=== prefix web
--- prefix chomp
web
--- love chomp
pig
--- animal chomp
shark
--- boin chomp
oppai
