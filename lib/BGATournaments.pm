package BGATournaments;

use strict;
use warnings;

use Dancer ':script';

get '/'                       => widget('Root');
get '/tournaments'            => widget('Tournaments');
get '/tournament/:tournament' => widget('Tournaments::OneTournament');

dance;

sub widget {
  my $widget = "BGATournaments::".shift();
  sub {
    eval "use $widget";
    $widget->run();
  }
}
