package BGATournaments::Root;

use strict;
use warnings;
use Dancer qw(:syntax);

sub run { {
  options => {
    'See all upcoming tournaments' => '/tournaments'
  }
} }

1;
