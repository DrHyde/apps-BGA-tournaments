package BGATournaments::Database::Result::Tournament;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('tournament');
__PACKAGE__->add_columns(qw(
  id name rounds class website
));

# FIXME inflate/defalte these
__PACKAGE__->add_columns(qw(
  start_date
  end_date 
));

__PACKAGE__->set_primary_key('id');
