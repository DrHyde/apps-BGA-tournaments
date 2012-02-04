package BGATournaments::Database::Result::Registration;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('registration');
__PACKAGE__->add_columns(qw(
  tournament_id email given_name family_name
  grade club country show_on_site
));

__PACKAGE__->belongs_to(
  tournament => 'BGATournaments::Database::Result::Tournament',
  { 'foreign.id' => 'self.tournament_id' }
);

__PACKAGE__->set_primary_key(qw(tournament_id email given_name family_name));
