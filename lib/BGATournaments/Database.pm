package BGATournaments::Database;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

use Dancer qw(:syntax);

__PACKAGE__->load_namespaces();

my $schema;
sub schema {
  my $class = shift;
  $schema ||= $class->connect(
    config()->{database}->{schema},
    config()->{database}->{user},
    config()->{database}->{pass}
  );
  return $schema;
}

1;
