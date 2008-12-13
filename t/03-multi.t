use Test::Base;
use Config::Any::YAML;
use Config::Multi;
use FindBin;
use File::Spec;
use File::Basename;
use Data::Dumper;

if ( !Config::Any::YAML->is_supported ) {
    plan skip_all => 'YAML format not supported';
}
else {
    plan tests => 3 * blocks ;
}

my $dir = File::Spec->catfile( $FindBin::Bin , 'conf' );

run { 
    my $block = shift;
    my $cm = Config::Multi->new({dir => $dir , app_name => 'myapp' , prefix => 'web' , extension => 'yml' });
    my $config = $cm->load();

    is( $block->boin , $config->{Boin} );
    is( $block->oppai , $config->{Oppai} );
    is( $block->cat , $config->{Cat} );
    
}

__END__
=== test
--- boin chomp
Boin
--- oppai chomp
Oppai
--- cat chomp
Cat

