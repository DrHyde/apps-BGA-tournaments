package BGATournaments::Widget::Admin;

use strict;
use warnings;
use Dancer qw(:syntax);

use base qw(BGATournaments::Widget);

sub admin {
  my $self = shift;
  my $database = $self->schema();
  my $tournament_id = params()->{tournament_id};
  my $database = $self->schema();

  if(session('user_id') && $database->resultset('TournamentLogin')->find({
    tournament_id => $tournament_id,
    email         => session('user_id'),
  })) {
    my $tournament = $database->resultset('Tournament')->find($tournament_id);
    return {
      template   => 'tournament-details.tt',
      tournament => $tournament,
      registrants => [$tournament->registrants()->all()],
      admin_mode  => 1,
    }
  }

  # or if not logged in ...
  session('target_page', "/tournaments/$tournament_id/admin");
  return redirect('/login');
}

1;
