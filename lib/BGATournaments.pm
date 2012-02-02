package BGATournaments;

use strict;
use warnings;

use Dancer ':syntax';

get '/tournaments'                => widget(Tournament => 'list');
get '/tournaments/:tournament_id' => widget(Tournament => 'details');

get '/'                           => widget('Root');

after sub {
  my $response = shift;
  use Data::Dumper;local $Data::Dumper::Indent=1;
  $response->{request} = request();
  my $route = request()->{_route_pattern};
  my $template = template_mapper($route);
  $response->{content} = template(
    $template,
    {
      dancer => {
        route => $route,
        template => $template,
      },
      %{$response->{content}}
    }
  );

  $response->{content} .= '<xmp>'.Dumper($response).'</xmp>';
};

sub template_mapper {
  my $route = shift;
  warn("Looking for $route\n");
  my $map = {
    '^/$'           => 'root',
    '^/tournaments$' => 'list-tournaments',
  };
  foreach my $re (keys %{$map}) {
    warn("Trying ".qr($re)."\n");
    if($route =~ /$re/) { return $map->{$re}.'.tt'; }
  }
  return "errors/notemplate.tt";
}

sub widget {
  my $widget = __PACKAGE__.'::'.shift;
  my $method = shift() || 'run';
  eval "use $widget; \@${widget}::ISA = '".__PACKAGE__."'; $widget->import()";
  if($@) {
    die("can't load $widget: $@\n");
  }
  return sub { $widget->$method() };
}

1;
