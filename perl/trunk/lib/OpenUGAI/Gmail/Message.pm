package OpenUGAI::Gmail::Message;

use strict;
use Carp;
use HTTP::Headers;

our $MIME_MULTIPART_BOUNDARY = "openugai_msgpart_";

sub new {
    my ($this, $to, $subject, $body, $token, $opt) = @_;
    my %fields = (
		  to => $to,
		  subject => $subject,
		  msgbody => $body,
		  at => $token,
		  cc => $opt->{cc} || "",
		  bcc => $opt->{bcc} || "",
		  view => "sd",
		  rm => "",
		  th => "",
		  draft => "",
		  cmid => "1",
		  _files => $opt->{files},
		  _boundary_string => $MIME_MULTIPART_BOUNDARY . $$,
		  );
    bless \%fields, $this;
}

sub getHeader {
    my $this = shift;
    return { "Content-Type" => "multipart/form-data; boundary=" . $this->{_boundary_string} };
    return new HTTP::Headers(
			     "Content-Type" => "multipart/form-data; boundary=" . $this->{_boundary_string},
			     );
}

sub getBody {
    my $this = shift;
    # TODO: need better data structure
    my $boundary_string = $this->{_boundary_string};
    # create body
    my $body = "";
    while (my ($key, $value) = each (%$this)) {
	next if ($key =~ /^\_/);
	$body .= "--" . $boundary_string . "\n";
	$body .= "Content-Disposition: form-data; name=\"" . $key . "\"\n\n";
	$body .= $value . "\n"; # TODO: need mime encoding
    }

    if ($this->{files}) {
	my $file_idx = 0;
	foreach (@{$this->{files}}) {
	    my $content_type = $_->{content_type};
	    my $contents = $_->{contents};
	    my $filename = $_->{name};
	    my $mailname = "file" . $file_idx;
	    $body .= "--" . $boundary_string . "\n";
	    $body .= "Content-Type: " . $content_type . "\n";
	    $body .= "Content-Disposition: form-data; name=\"" . $mailname . "\"; filename=\"" . $filename . "\"\n\n";
	    $body .= $contents . "\n";
	}
    }
    $body .= "--" . $boundary_string . "--\n";
    $body =~ s/\n/\r\n/g;
    return $body;
}

1;
