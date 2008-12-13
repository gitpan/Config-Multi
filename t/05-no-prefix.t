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
    plan tests => 1 * blocks ;
}

my $dir = File::Spec->catfile( $FindBin::Bin , 'conf' );

run { 
    my $block = shift;
    my $config = Config::Multi->new({dir => $dir , app_name => 'myapp'  });
    $config->load();
    my $paths = $config->files;
    my @files= ();
    for my $path ( @{ $paths } ) {
       my ( $filename ) = fileparse( $path );
       push @files, ($filename);  
    }

    @files = sort(@files);
    my @expected = @{ $block->expected };
    @expected = sort(@expected);
    
    ok( eq_array( \@files ,\@expected ) );
}

__END__
=== prefix myapp
--- expected eval
[qw/
myapp_boin.yml
myapp.yml
myapp_oppai.yml
myapp_local.yml
/]
