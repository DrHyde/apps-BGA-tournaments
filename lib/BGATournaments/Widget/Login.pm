package BGATournaments::Widget::Login;

use strict;
use warnings;
use Dancer qw(:syntax);
use DateTime;
use DateTime::Format::MySQL;
use Data::UUID;
use Digest::MD5 qw(md5_base64);
use MIME::Lite;

use base qw(BGATournaments::Widget);

sub loginform { }
sub loginformresults {
  my $self = shift;
  my $email = params()->{email};
  my $pw_plain = params()->{password};
  my $pw_md5   =md5_base64($pw_plain);

  my $database = $self->schema();

  my $login = $database->resultset('Login')->search({ email => $email, pw_md5 => $pw_md5})->first();

  if(!$login) {
    return {
      template => 'login-loginform.tt',
      error    => 'login failed',
      email    => $email
    }
  }
  return {}
}

1;
