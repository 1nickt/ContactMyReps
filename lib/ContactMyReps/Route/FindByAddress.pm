=head1 NAME

ContactMyReps::Route::FindByAddress - Handles /find-by-address

=head1 DESCRIPTION

Form for looking up officials by address.

=cut

package ContactMyReps::Route::FindByAddress;

use Dancer2 appname => 'ContactMyReps';
use Encode;
use Path::Tiny;
use Try::Tiny;

use Net::Google::CivicInformation::Representatives;

get '/find-by-address' => sub {
    my $params = params;
    return template 'find-by-address', {
        recaptcha_key => config->{recaptcha}{site_key},
    };
};

post '/find-by-address' => sub {
    my $params = params;

    if ( not $params->{address} ) {
        send_error('Error: address is required.', 400 );
    }

    my $log = path('/var/log/ContactMyReps-queries.txt');

    $log->append("$params->{address}\n");

    my $client = Net::Google::CivicInformation::Representatives->new;

    my %result = ( address => $params->{address} );

    my $response = $client->representatives_for_address($params->{address});

    if ( $response->{error} ) {
        $result{error} = $response->{error};
    }
    else {
        $result{officials} = decode_utf8(encode_json($response->{officials}));
    }

    $result{recaptcha_key} = config->{recaptcha}{site_key};

    return template 'find-by-address', \%result;
};

1; # return true

