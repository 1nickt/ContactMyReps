=head1 NAME

ContactMyReps::Route::Contact - Handles /contact

=head1 DESCRIPTION

Sends content from a form via email.

=cut

package ContactMyReps::Route::Contact;

use Dancer2 appname => 'ContactMyReps';
use Dancer2::Plugin::Email;
use Dancer2::Plugin::reCAPTCHA;
use Try::Tiny;

get '/contact' => sub {
    my $params = params;
    my $bypass_recaptcha = $params->{'bypass_recaptcha'} || 0 == 42;
    return template 'contact', {
        recaptcha => recaptcha_display(),
        $bypass_recaptcha ? ( bypass_recaptcha => 1 ) : (),
    };
};

post '/contact' => sub {
    my $params = params;

    if ( not $params->{'bypass_recaptcha'} and not recaptcha_verify( $params->{'g-recaptcha-response'} )->{'success'} ) {
        send_error( 'Sorry, you look like a robot. Access denied. If you are a human, with good intentions, please go back and try again.', 401 );
    } else {
        try {
            email {
                type    => 'plain',
                from    => 'nick@nicktonkin.net',
                to      => '1nickt@gmail.com',
                subject => 'Contact form from contactmyreps.com',
                body    => join( "\n\n",
                                 "Dear Nick, someone wants you:",
                                 "From:\n$params->{'sender'}",
                                 "Subject:\n$params->{'subject'}",
                                 "Message:\n$params->{'body'}"    ),

            };
        } catch {
            error "Could not send email: $_";
        };

        return template 'generic.tt', { content => 'Thank you for your message.' };
    }
};


1; # return true

