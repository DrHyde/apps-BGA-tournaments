package BGATournaments::Database::Result::TournamentClass;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('tournament_classes');
__PACKAGE__->add_columns(qw(
  tournament_id class_name price
));

# FIXME inflate/defalte these
__PACKAGE__->add_columns(qw(
  until
));

__PACKAGE__->belongs_to(
  registrants => 'BGATournaments::Database::Result::Tournament',
  { 'foreign.id' => 'self.tournament_id' }
);

__PACKAGE__->set_primary_key(qw(tournament_id class_name until));
