package BGATournaments::Widget::Tournament;

use strict;
use warnings;
use Dancer qw(:syntax);

use base qw(BGATournaments::Widget);

my @mandatory_reg_fields = qw(given_name family_name country grade);
my @all_reg_fields = (@mandatory_reg_fields, 'club');

sub list {
  my $self = shift;
  my $database = $self->schema();
  my @rows = $database->resultset('Tournament')->all();
  return { tournaments => \@rows };
}

sub details {
  my $self = shift;
  my $database = $self->schema();
  my $tournament_id = params()->{tournament_id};
  my $tournament = $database->resultset('Tournament')->find($tournament_id);
  return {} unless($tournament);
  return { tournament => $tournament };
}

sub _reg_form_as_hash { map { $_ => params()->{$_} } @all_reg_fields; }
sub registerform {
  my $self = shift;
  my $tournament_id = params()->{tournament_id};
  my %form = _reg_form_as_hash();
  return {
    tournament => { id => $tournament_id },
    form       => \%form
  };
}

sub registerformresults {
  my $self = shift;
  my $tournament_id = params()->{tournament_id};
  my %form = _reg_form_as_hash();
  foreach (@mandatory_reg_fields) {
    if(!$form{$_}) {
      return {
        tournament => { id => $tournament_id },
        form       => \%form,
        template   => 'tournament-registerform.tt',
      };
    }
  }
  return { cows => 'go moo' };
}

1;
