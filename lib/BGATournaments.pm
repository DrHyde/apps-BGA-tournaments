package BGATournaments;

use strict;
use warnings;

use constant DEBUG => 0;
use Data::Dumper;

use Dancer ':syntax';
use BGATournaments::Widget;
use BGATournaments::Database;

get  '/tournaments'                                          => widget(Tournament => 'list');
get  '/tournaments/:tournament_id'                           => widget(Tournament => 'details');
get  '/tournaments/:tournament_id/registerform'              => widget(Tournament => 'registerform');
post '/tournaments/:tournament_id/registerresults'           => widget(Tournament => 'registerformresults');
get  '/tournaments/:tournament_id/editregistration/:editkey' => widget(Tournament => 'editregisterform');
post '/tournaments/:tournament_id/editregistrationresults'   => widget(Tournament => 'editregisterformresults');

get  '/tournaments/:tournament_id/admin'                     => widget(Admin      => 'admin');
get  '/login'                                                => widget(Login      => 'loginform');
post '/login'                                                => widget(Login      => 'loginformresults');

get  '/'                                                     => widget('Root');

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

  return sub {
    my $route = request()->{_route_pattern};
    my $widget = $widgetclass->new();
    my $results = $widget->$method();
    my $rendered = template(
      ($results->{template} || $template),
      {
        dancer => { route => $route, template => $template, },
        %{$results}
      }
    );
    local $Data::Dumper::Indent = 1;
    $rendered .= '<xmp>'.Dumper($results).'</xmp>' if(DEBUG);
    $rendered;
  };
}

1;
