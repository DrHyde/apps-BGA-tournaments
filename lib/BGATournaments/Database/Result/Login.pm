package BGATournaments::Database::Result::Login;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('login');
__PACKAGE__->add_columns(qw(
  email pw_md5
));

__PACKAGE__->set_primary_key(qw(email));
