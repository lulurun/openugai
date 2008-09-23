package OpenUGAI::Gmail::Message;

use strict;
use Carp;
use HTTP::Headers;
use HTML::TokeParser;

sub ParseMailPage {
    my $html_string = shift;
    print $html_string . "\n\n";
    my $p = new HTML::TokeParser(\$html_string);
    my $page_script = "";
    while ( my $token = $p->get_tag("script") ) {
	my $script_text = $p->get_trimmed_text("/script");
	if ($script_text =~ /^<!--\s+(.+)\s+\/\/-->$/) {
	    $script_text = $1;
	}
	next if ($script_text !~ /^D\((.+)\);$/);
	$page_script .= $script_text;
    }
    my $script_parser = new OpenUGAI::Gmail::Message::ScriptParser();
    my $mail_data = $script_parser->getMailData($page_script);
    my $mail = new OpenUGAI::Gmail::Message::Detail($mail_data->{di});
    return $mail;
}

sub ParseMailListPage {
    my $html_string = shift;
    my $p = new HTML::TokeParser(\$html_string);
    my $page_script = "";
    while ( my $token = $p->get_tag("script") ) {
	my $script_text = $p->get_trimmed_text("/script");
	if ($script_text =~ /^<!--\s+(.+)\s+\/\/-->$/) {
	    $script_text = $1;
	}
	next if ($script_text !~ /^D\((.+)\);$/);
	$page_script .= $script_text;
    }
    my $script_parser = new OpenUGAI::Gmail::Message::ScriptParser();
    my $mail_data = $script_parser->getMailData($page_script);
    my @mail_list = ();
    foreach my $mail (@{$mail_data->{t}}) {
	push @mail_list, new OpenUGAI::Gmail::Message::Summary($mail);
    }
    return \@mail_list;
}

package OpenUGAI::Gmail::Message::Detail;

sub new {
    my ($this, $gmail_obj) = @_;
    my %fields = (
		  to => $gmail_obj->{to},
		  from => $gmail_obj->{from},
		  subject => $gmail_obj->{subject},
		  body => $gmail_obj->{body},
		  datetime => $gmail_obj->{datetime},
		  attachments => $gmail_obj->{attachments},
		  );
    bless \%fields, $this;
}

package OpenUGAI::Gmail::Message::Summary;

sub new {
    my ($this, $params) = @_;
    my %fields = (
		  th_id => $params->[0],
		  unread => $params->[1],
		  star => $params->[2],
		  date_html => $params->[3],
		  author_html => $params->[4],
		  flags => $params->[5],
		  subject => $params->[6],
		  uk1 => $params->[7],
		  categories => $params->[8],
		  attach => $params->[9],
		  m_id => $params->[10],
		  uk2 => $params->[11],
		  datetime => $params->[12],
		  uk3 => $params->[13],
		  uk4 => $params->[14],
		  uk5 => $params->[15],
		  uk6 => $params->[16],
		  uk7 => $params->[17],
		  );
    bless \%fields, $this;
}

package OpenUGAI::Gmail::Message::Compose;

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

package OpenUGAI::Gmail::Message::ScriptParser;

sub new {
    my $this = shift;
    my %fields = (
		  gmail_data => undef,
		  );
    bless \%fields, $this;
}

sub getMailData {
    my ($this, $script) = @_;
    $script =~ s/\$/\\\$/g;
    $script =~ s/\@/\\\@/g;
    $script =~ s/\%/\\\%/g;
    $script =~ s/D\(/\$this\-\>D\(/g;
    while ($script =~ s/\,\,/\,undef\,/g) {
	; # TODO: who is better than WD ?
    }
    eval $script;
    if ($@) {
	print "Error: $@\n";
    }
    return $this->{gmail_data};
}

sub D {
    my ($this, $data) = @_;
    my $name = shift @$data;
    if ($this->{gmail_data}->{$name}) {
	push @{$this->{gmail_data}->{$name}}, @$data;
    } else {
	$this->{gmail_data}->{$name} = $data;
    }
}

1;

