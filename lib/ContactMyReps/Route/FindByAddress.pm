=head1 NAME

ContactMyReps::Route::FindByAddress - Handles /find-by-address

=head1 DESCRIPTION

Form for looking up officials by address.

=cut

package ContactMyReps::Route::FindByAddress;

use Dancer2 appname => 'ContactMyReps';
use Encode;
use Try::Tiny;

use Net::Google::CivicInformation::Representatives;

get '/find-by-address' => sub {
    my $params = params;
    return template 'find-by-address';
};

=pod

post '/find-by-address' => sub {
    my $params = params;

    debug("looking up $params->{address}");

    if ( not $params->{address} ) {
        send_error('Error: address is required.', 400);
    }

    my $client = Net::Google::CivicInformation::Representatives->new;

    my %result = ( address => $params->{address} );

    my $response = $client->representatives_for_address($params->{address});

    if ( $response->{error} ) {
        $result{error} = $response->{error};
    }
    else {
        $result{officials} = decode_utf8(encode_json($response->{officials}));
    }

    debug('returning response');

    return template 'find-by-address', \%result;
};

=cut

1; # return true

