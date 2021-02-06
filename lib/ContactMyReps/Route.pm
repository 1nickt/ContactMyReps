=head1 NAME

ContactMyReps::Route - The route handler loader

=cut

use Dancer2;
use Module::Runtime qw/ require_module /;

my $base = 'ContactMyReps::Route::';

my %required_modules = (
    FindByAddress => 1,
    Contact       => 1,
);

require_module( $base . $_ ) for grep { $required_modules{ $_ } == 1 } ( keys %required_modules );

get '/' => sub {
    forward '/find-by-address';
};

1; # return true
