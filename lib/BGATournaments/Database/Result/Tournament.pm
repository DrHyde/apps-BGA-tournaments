package BGATournaments::Database::Result::Tournament;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('tournament');
__PACKAGE__->add_columns(qw(
  id name rounds class website email
));

# FIXME inflate/defalte these
__PACKAGE__->add_columns(qw(
  start_date
  end_date 
));

__PACKAGE__->has_many(
  registrants => 'BGATournaments::Database::Result::Registration',
  { 'foreign.tournament_id' => 'self.id' }
);

__PACKAGE__->has_many(
  tournament_classes => 'BGATournaments::Database::Result::TournamentClass',
  { 'foreign.tournament_id' => 'self.id' }
);

sub current_classes {
  my $self = shift;
  my @all_classes = sort {
    $a->until() cmp $b->until()
  } $self->tournament_classes_rs->search_literal('until > now()');
  my %seen = ();
  foreach my $class (@all_classes) {
    if(!$seen{$class->class_name}) {
      $seen{$class->class_name} = $class;
    }
  }
  return values(%seen);
}

sub total_registered {
  my $self = shift;
  $self->registrants_rs()->count();
}

sub total_hidden {
  my $self = shift;
  $self->registrants_rs()->search({ show_on_site => 0 })->count();
}

sub people_to_show {
  my $self = shift;
  $self->registrants_rs()->search({ show_on_site => 1 })->all();
}

__PACKAGE__->set_primary_key('id');
