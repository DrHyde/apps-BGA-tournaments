package BGATournaments::Widget::Tournament;

use strict;
use warnings;

sub list {
  my $self = shift;
  my $database = $self->{schema};
  my @rows = $database->resultset('Tournament')->all();
  return { tournaments => \@rows };
}

sub details {
  my $self = shift;
  my $database = $self->{schema};
  my $tournament_id = $self->params()->{tournament_id};
  my $tournament = $database->resultset('Tournament')->find($tournament_id);
  return {} unless($tournament);
  return { tournament => $tournament };
}

1;
