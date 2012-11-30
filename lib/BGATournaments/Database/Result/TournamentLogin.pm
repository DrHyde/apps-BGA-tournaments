package BGATournaments::Database::Result::TournamentLogin;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('tournament_login');
__PACKAGE__->add_columns(qw(
  email tournament_id
));

__PACKAGE__->set_primary_key(qw(email tournament_id));
