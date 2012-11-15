package BGATournaments::Widget::Admin;

use strict;
use warnings;
use Dancer qw(:syntax);

use base qw(BGATournaments::Widget);

sub admin {
  my $self = shift;
  my $database = $self->schema();
  my $tournament_id = params()->{tournament_id};
  # my $tournament = $database->resultset('Tournament')->find($tournament_id);

  if(session('user_id')) {
    ...
  } else {
    session('target_page', "/tournaments/$tournament_id/admin");
    return redirect('/login');
  }
  return { FIXME => '...' };
}

1;
