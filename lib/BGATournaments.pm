package BGATournaments;

use strict;
use warnings;

use constant DEBUG => 1;
use Data::Dumper;
local $Data::Dumper::Indent = 1;

use Dancer ':syntax';

get '/tournaments'                => widget(Tournament => 'list');
get '/tournaments/:tournament_id' => widget(Tournament => 'details');

get '/'                           => widget('Root');

sub widget {
  my $widget = shift;
  my $method = shift() || 'run';
  (my $template = lc("${widget}-$method.tt")) =~ s/::/-/g;
  if(!-e "views/$template") {
    $template = "errors-notemplate.tt";
  }
  $widget = __PACKAGE__.'::'.$widget;
  eval "use $widget";
  if($@) {
    die("can't load $widget: $@\n");
  }
  return sub {
    my $route = request()->{_route_pattern};
    my $results = $widget->$method();
    my $rendered = template $template, {
      dancer => { route => $route, template => $template, },
      %{$results}
    };
    $rendered .= '<xmp>'.Dumper($results).'</xmp>' if(DEBUG);
  };
}

1;
