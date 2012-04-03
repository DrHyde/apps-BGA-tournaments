package BGATournaments::Widget::Tournament;

use strict;
use warnings;
use Dancer qw(:syntax);
use DateTime;
use DateTime::Format::MySQL;
use Data::UUID;
use Digest::MD5 qw(md5_base64);

use base qw(BGATournaments::Widget);

my @mandatory_reg_fields = qw(email given_name family_name country grade);
my @all_reg_fields = (@mandatory_reg_fields, qw(club show_on_site bga_member));

sub list {
  my $self = shift;
  my $database = $self->schema();
  my @rows = $database->resultset('Tournament')->search({
    start_date => { '>' => DateTime::Format::MySQL->format_date(DateTime->now()) },
  })->all();
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

sub editregisterform {
  my $self = shift;
  my $tournament_id = params()->{tournament_id};
  my $registration = $self->schema()->resultset('Registration')->find({editkey => params()->{editkey}});
  if(!$registration) {
    return {
      tournament => $tournament_id,
      template   => 'tournament-details.tt',
      message    => 'wrongkey',
    };
  }
  return {
    tournament => $tournament_id,
    template   => 'tournament-registerform.tt',
    form       => {
      map { $_ => $registration->$_() } (@all_reg_fields, 'editkey')
    },
    nextaction => 'editregistrationresults',
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

  my $database = $self->schema();
  my $tournament = $database->resultset('Tournament')->find($tournament_id);
  my $registration = $database->resultset('Registration')->find({
    map { $_ => params()->{$_} } qw(tournament_id email given_name family_name)
  });

  my $return = {
    tournament => $tournament,
    template   => 'tournament-details.tt',
  };

  if($registration) {
    # already registered
    return { %{$return}, message => 'alreadyregistered' };
  };
  eval {
    $registration = $database->resultset('Registration')->create({
      (map { $_ => params()->{$_} } ('tournament_id', @mandatory_reg_fields)),
      show_on_site => (params()->{show_on_site} ? 1 : 0),
      bga_member   => (params()->{bga_member}   ? 1 : 0),
      (params()->{club} ? (club => params()->{club}) : ()),
      editkey => md5_base64(rand().$$.Data::UUID->new()->create_str())
    });
  };
  my $message = $@ ? 'regfailed' : 'registered';
  if($message eq 'registered') {
    # FIXME send email
  }
  return { %{$return},
    message      => $message,
    registration => $registration,
  };
}

sub editregisterformresults {
  my $self = shift;
  my $tournament_id = params()->{tournament_id};
  my %form = (_reg_form_as_hash(), editkey => params()->{editkey});;

  foreach (@mandatory_reg_fields) {
    if(!$form{$_}) {
      return {
        tournament => { id => $tournament_id },
        form       => \%form,
        template   => 'tournament-registerform.tt',
        nextaction => 'editregistrationresults',
      };
    }
  }

  my $database = $self->schema();
  my $tournament = $database->resultset('Tournament')->find($tournament_id);
  my $registration = $database->resultset('Registration')->find({ editkey => params()->{editkey} }); 

  my $return = {
    tournament => $tournament,
    template   => 'tournament-details.tt',
  };

  if(!$registration) {
    # already registered
    return { %{$return}, message => 'notalreadyregistered' };
  };
  foreach my $field (@mandatory_reg_fields, 'club') {
    $registration->$field(params()->{$field});
  }
  $registration->show_on_site(params()->{show_on_site} ? 1 : 0);
  $registration->bga_member(params()->{bga_member} ? 1 : 0);
  $registration->update();

    # FIXME send email
  return { %{$return},
    message      => 'edited',
    registration => $registration,
  };
}

1;
