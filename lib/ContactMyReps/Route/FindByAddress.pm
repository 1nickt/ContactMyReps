=head1 NAME

ContactMyReps::Route::FindByAddress - Handles /find-by-address

=head1 DESCRIPTION

Form for looking up officials by address.

=cut

package ContactMyReps::Route::FindByAddress;

use Dancer2 appname => 'ContactMyReps';
use Encode;
use Try::Tiny;

use WebService::GeoCodio;
use WebService::OpenStates;

get '/find-by-address' => sub {
    my $params = params;
    return template 'find-by-address';
};

post '/find-by-address' => sub {
    my $params = params;

    if ( ! $params->{address} ) {
        send_error('Error: address is required.', 400);
    }

    debug("looking up $params->{address}");

    my %result = ( address => $params->{address} );

    my $geo_response = try {
        my $geo = WebService::Geocodio->new(api_key => $ENV{GEOCODIO_API_KEY});
        $geo->add_location($params->{address});
        return $geo->geocode;
    }
    catch {
        return { error => $_ };
    };

    if ( ref($geo_response) eq 'HASH' && $geo_response->{error} ) {
        $result{error} = $geo_response->{error};
        return template 'find-by-address', \%result;
    }
    elsif ( scalar(@$geo_response > 1) || $geo_response->[0]->accuracy < 1 || $params->{address} !~ $geo_response->[0]->city ) {
        $result{error}{message} = 'Address not found';
        return template 'find-by-address', \%result;
    }

    my ($lat, $lon, $found_address) = ($geo_response->[0]->lat, $geo_response->[0]->lng, $geo_response->[0]->formatted);

    debug("got lat/lon $lat/$lon for $found_address");

    $result{found_address} = $found_address;

    my $os_response = try {
        my $os = WebService::OpenStates->new(api_key => $ENV{OPENSTATES_API_KEY});
        return $os->legislators_for_location(lat => $lat, lon => $lon);
    }
    catch {
        return { error => $_ };
    };

    if ($os_response->{error}) {
        $result{error}{message} = $os_response->{error};
        return template 'find-by-address', \%result;
    }

    $result{legislators} = decode_utf8(encode_json($os_response->{legislators}));

    debug('returning result');

    return template 'find-by-address', \%result;
};

1; # return true

