package BGATournaments::Widget;

use strict;
use warnings;

sub new {
  my $class = shift;
  bless({ @_ }, $class);
}

sub params { return shift()->{params}; }
sub request { return shift()->{request}; }
sub route { return shift()->{route}; }

sub run { {} }

1;
