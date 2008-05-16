use FindBin::libs;
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
    local $ENV{$block->env_key} = File::Spec->catfile( $FindBin::Bin ,'conf', $block->file ) ;
    my $cm = Config::Multi->new({dir => $dir , app_name => 'myapp' , prefix => 'web'  });
    my $config = $cm->load();

    is( $block->porn , $config->{porn} );
    
}

__END__
=== test app
--- env_key chomp
CONFIG_MULTI_MYAPP
--- file chomp
env.yml
--- porn chomp
oppai
=== test prefi
--- env_key chomp
CONFIG_MULTI_WEB_MYAPP
--- file chomp
env-prefix.yml
--- porn chomp
tinna
