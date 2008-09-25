#!/usr/bin/perl -w

use strict;
use Data::Dump;

use OpenUGAI::Gmail::Account;

my $sample_text =<< "SAMPLE_TEXT";
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789
SAMPLE_TEXT

my $gacc = new OpenUGAI::Gmail::Account("luluasset", "1u1u\@sset");
$gacc->login();
print "login success\n\n";

#&send_mail();
#print "send mail: gmail_test\n\n";

my $mail_list = &get_mail_list();
print "get mail contents ...\n\n";

#foreach (@$mail_list) {
#    &get_mail($_->{m_id});
#}
print "done.\n\n";

# ######################
# test functions
sub get_mail_list {
    my $messages = $gacc->getMessage( {folder => "drafts"} );
    foreach (@$messages) {
	print $_->{m_id} . ": " . $_->{subject} . "\n";
    }
    print "\n";
    return $messages;
}

sub get_mail {
    my $m_id = shift;
    print "get mail $m_id ...\n";
    my $mail = $gacc->getMessage( {folder => "drafts", msg_id => $m_id} );
    print Data::Dump::dump($mail) . "\n";
    my $att_info = $mail->getAttInfo(0);
    if ($att_info) {
	my %att_args = (
			a_id => $att_info->{a_id},
			m_id => $mail->{m_id},
			);
	my $att= $gacc->getAttachment(\%att_args);
	print Data::Dump::dump($att) . "\n";
    }
    print "\n";
}

sub send_mail {
    $gacc->sendMessage("luluasset\@gmail.com", "gmail_test", $sample_text);
}

