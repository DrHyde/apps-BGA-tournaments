package BGATournaments::Widget;

use strict;
use warnings;

use Dancer qw(:syntax);

sub new {
  my $class = shift;
  bless({ @_ }, $class);
}

sub schema { BGATournaments::Database->schema() }
sub route  { request()->{_route_pattern} }

sub run { {} }

1;
