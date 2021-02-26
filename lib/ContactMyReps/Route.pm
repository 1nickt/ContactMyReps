=head1 NAME

ContactMyReps::Route - The route handler loader

=cut

use Dancer2;
use Module::Runtime 'require_module';

my $module_base = 'ContactMyReps::Route::';

my %modules = %{ config->{route_modules} };

my @required_modules = grep { $modules{$_} } keys %modules;

require_module( $module_base . $_ ) for @required_modules;

get '/' => sub {
    forward '/find-by-address';
};

1; # return true
