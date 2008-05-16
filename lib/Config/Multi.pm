package Config::Multi;

use strict;
use warnings;
use DirHandle;
use File::Spec;
use FindBin;
use Config::Any ;
use Carp;

use base qw/Class::Accessor/;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw/app_name prefix dir files extension/);

sub load {
    my $self = shift;
    my @files = ();
    $self->{extension} ||= 'yml';
    croak( 'you must set dir' ) unless $self->{dir};
    croak( 'you must set app_name' ) unless $self->{app_name};

    my $config = {};

    my $app_files    = $self->_find_files( $self->{app_name} ) ;
    my $app = Config::Any->load_files( { files => $app_files } );
    for ( @{$app} ){
        my ($filename, $data) = %$_;
        push @files , $filename;
        $config = { %{$config}, %{$data} } ;
    }

    if( $self->{prefix} ) {
        my $prefix_files = $self->_find_files( $self->{prefix} . '_' . $self->{app_name} );
        my $prefix =  Config::Any->load_files( { files => $prefix_files } );
        for ( @{$prefix} ){
            my ($filename, $data) = %$_;
            push @files , $filename;
            $config = { %{$config}, %{$data} } ;
        }
    }

    my $local_files = $self->_local_files;
    my $local =  Config::Any->load_files( { files => $local_files } );
    for ( @{$local} ){
        my ($filename, $data) = %$_;
        push @files , $filename;
        $config = { %{$config}, %{$data} } ;
    }

    $self->{files} = \@files;

    return $config;
}


sub _local_files {
    my $self = shift;
    my $env_app_key    = 'CONFIG_MULTI_' .uc($self->{app_name})  ;
    my $env_prefix_key = 'CONFIG_MULTI_' . uc($self->{prefix}) . '_' . uc($self->{app_name})  ;
    my @files = ();
    my $app_lcoal    = $ENV{ $env_app_key } || File::Spec->catfile( $self->dir ,  $self->{app_name} . '_local.' . $self->extension ) ;
    push @files  , $app_lcoal if -e $app_lcoal;

    if( $self->{prefix}) {
        my $prefix_local = $ENV{ $env_prefix_key} || File::Spec->catfile( $self->dir ,  $self->{prefix} . '_' . $self->{app_name} . '_local.' . $self->extension );
        push @files  , $prefix_local if -e $prefix_local;
    }

    return \@files;
}

sub _find_files {
    my $self = shift;
    my $path = $self->dir;
    my $label = shift;
    my $extension = $self->extension;

    my @files;
   my $dh = DirHandle->new( $path ) or croak "Could not Open " . $path ;

    while ( my $file = $dh->read() ) {
        next if $file =~ /local\.$extension$/;
        if( $file =~ /^$label\.yml$/ || $file =~ /^$label\_(\w+)\.$extension$/ ) {
            push @files , "$path/$file";
        }
    }

    return \@files;
}


1;

=head1 NAME

Config::Multi - load multiple config files.

=head1 SYNOPSIS

 use Config::Multi;
 use File::Spec;
 use FindBin;
 
 my $dir = File::Spec->catfile( $FindBin::Bin , 'conf' );

 # prefix and extension is optional. 
 my $cm =  Config::Multi->new({dir => $dir , app_name => 'myapp' , prefix => 'web' , extension => 'yml' });
 my $config = $cm->load();
 my $loaded_config_files = $cm->files;

=head1 DESCRIPTION

This module load multiple config files using L<Config::Any>. You can specify directory and put into your config files!

I create this module because I want to load not only loading multiple config files but also switch config files depend on interface I am using. like,  I want to load web.yml only for web interface configuration and cli.yml for only for client interface configuration. let me explain step by step at EXAMPLE section.

=head1 EXAMPLE

=head2 your configuration files

  This is under your ~/myapp/conf/ and have sone yaml configuration in each files. you can specify the directory 
  using dir option.

 .
 |-- env-prefix.yml
 |-- env.yml
 |-- myapp.yml
 |-- myapp_boin.yml
 |-- myapp_local.yml
 |-- myapp_oppai.yml
 |-- never_load.yml
 |-- web_myapp.yml
 |-- web_myapp_cat.yml
 |-- web_myapp_dog.yml
 `-- web_myapp_local.yml

=head2 switchable 

when you set app_name as 'myapp' and prefix as 'jobqueue' then below files are loaded

 |-- myapp.yml
 |-- myapp_boin.yml
 |-- myapp_local.yml
 |-- myapp_oppai.yml

${app_name}.yml or ${app_name}_*.yml

when you set app_name as 'myapp' and prefix as 'web' then below files are loaded

 |-- myapp.yml
 |-- myapp_boin.yml
 |-- myapp_local.yml
 |-- myapp_oppai.yml
 |-- web_myapp.yml
 |-- web_myapp_cat.yml
 |-- web_myapp_dog.yml
 `-- web_myapp_local.yml

${prefix}_${myapp}.yml ${prefix}_${myapp}_*.yml

YES! you can switch config files depend on what you set for app_name and prefix. 

=head2 overwrite rule.

there is also overwriting rule. there are three steps for this.


_local.yml file overwrite the other config setting

 ${prefix}_${app_name}_local.yml
 ${app_name}_local.yml

${prefix}_ files overwrite ${app_name} config setting

 ${app_name}.yml, ${app_name}_*.yml  (not include ${app_name}_local.yml)

app config.

 ${prefix}_${myapp}.yml ${prefix}_${myapp}_*.yml

=head2 $ENV setting

instead of ${prefix}_${app_name}_local.yml , you can specify the path with $ENV{CONFIG_MULTI_PREFIX_MYAPP}
instead of ${app_name}_local.yml , you can specify the path with $ENV{CONFIG_MULTI_MYAPP}

note. PREFIX = uc($prefix); MYAPP = uc($app_name)

=head1 METHODS

=head2 new
 
constructor SEE CONSTRUCTOR ARGUMENT section.

=head2 load

load config files and return config data.

=head2 files

get array references of loaded config files. You can use this method after call load() method.

=head1 CONSTRUCTOR ARGUMENT

=head2 app_name

your application name. use [a-z]+ for format. 

=head2 prefix

prefix name . use [a-z]+ for format. this is optional. if you did not set. only application config is loaded(include appname_local.yml if you have. )

=head2 dir

specify directory where your config files are located.

=head2 extension

you must specify extension for your config files. default is yml.

=head1 SEE ALSO

L<Config::Any>

=head1 AUTHOR

Tomohiro Teranishi <tomohiro.teranishi@gmail.com>

=head1 COPYRIGHT

This module is copyright 2008 Tomohiro Teranishi. 

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

