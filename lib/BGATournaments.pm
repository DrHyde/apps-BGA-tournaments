package BGATournaments;

use strict;
use warnings;

use Dancer ':syntax';

get '/'                           => widget('Root');
get '/tournaments'                => widget('Tournament');
# get '/tournaments/:tournament_id' => widget('Tournament::Details');

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
    '/(:foo)?' => 'root'
  };
  foreach my $re (keys %{$map}) {
    warn("Trying ".qr($re)."\n");
    if($route =~ /^$re$/) { return $map->{$re}.'.tt'; }
  }
  return "errors/notemplate.tt";
}

sub widget {
  my $widget = __PACKAGE__.'::'.shift;
  eval "use $widget; \@${widget}::ISA = '".__PACKAGE__."'; $widget->import()";
  if($@) {
    die("can't load $widget: $@\n");
  }
  return sub { $widget->run() };
}

1;
