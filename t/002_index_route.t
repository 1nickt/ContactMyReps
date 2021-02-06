use strict;
use warnings;

use ContactMyReps;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

my $app = ContactMyReps->to_app;
is( ref $app, 'CODE', 'Got app' );

my $test = Plack::Test->create($app);

my $res  = $test->request( GET '/' );
ok( $res->is_success, '[GET /] successful' );

done_testing;
