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
  return {};
}

1;
