package BGATournaments;

use strict;
use warnings;

use constant DEBUG => 1;
use Data::Dumper;

use Dancer ':syntax';
use BGATournaments::Widget;
use BGATournaments::Database;

get '/tournaments'                => widget(Tournament => 'list');
get '/tournaments/:tournament_id' => widget(Tournament => 'details');

get '/'                           => widget('Root');

sub widget {
  my $widgetclass = shift;
  my $method = shift() || 'run';
  (my $template = lc("${widgetclass}-$method.tt")) =~ s/::/-/g;
  if(!-e "views/$template") {
    $template = "errors-notemplate.tt";
  }
  $widgetclass = __PACKAGE__.'::Widget::'.$widgetclass;
  eval "use $widgetclass";
  if($@) {
    die("can't load $widgetclass: $@\n");
  }

  eval "push \@${widgetclass}::ISA, '".__PACKAGE__."::Widget'";

  return sub {
    my $route = request()->{_route_pattern};
    my $widget = $widgetclass->new(
      params   => params() || {},
      request  => request(),
      route    => $route,
      schema   => BGATournaments::Database->schema(),
    );
    my $results = $widget->$method();
    my $rendered = template $template, {
      dancer => { route => $route, template => $template, },
      %{$results}
    };
    local $Data::Dumper::Indent = 1;
    $rendered .= '<xmp>'.Dumper($results).'</xmp>' if(DEBUG);
  };
}

1;
