=head1 NAME

ContactMyReps::Route::Email - Handles /email

=head1 DESCRIPTION

Sends content from a form via email.

=cut

package ContactMyReps::Route::Email;

use Dancer2 appname => 'ContactMyReps';
use Dancer2::Plugin::Email;
use Try::Tiny;

get '/email' => sub {
    my $params = params;
    return template 'email';
};

post '/email' => sub {
    my $params = params;

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
};


1; # return true

