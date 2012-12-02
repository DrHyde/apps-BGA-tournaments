package BGATournaments::Widget::Tournament;

use strict;
use warnings;
use Dancer qw(:syntax);
use DateTime;
use DateTime::Format::MySQL;
use Data::UUID;
use Digest::MD5 qw(md5_base64);
use MIME::Lite;

use base qw(BGATournaments::Widget);

my @mandatory_reg_fields = qw(email given_name family_name country grade class);
my @all_reg_fields = (@mandatory_reg_fields, qw(club show_on_site bga_member notes));

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
  return {
    tournament  => $tournament,
    registrants => [$tournament->people_to_show()]
  };
}

sub _reg_form_as_hash { map { $_ => params()->{$_} } @all_reg_fields; }
sub registerform {
  my $self = shift;
  my $tournament_id = params()->{tournament_id};
  my $tournament = $self->schema()->resultset('Tournament')->find($tournament_id);
  my %form = (
    _reg_form_as_hash(),
    map { 'round'.$_ => 1 } (1 .. $tournament->rounds())
  );
  return {
    tournament => { id => $tournament_id },
    tournament_obj => $tournament,
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
  my @rounds = split(/,/, $registration->rounds());
  my $tournament = $self->schema()->resultset('Tournament')->find($tournament_id);
  return {
    tournament => $tournament_id,
    tournament_obj => $tournament,
    template   => 'tournament-registerform.tt',
    form       => {
      (map { $_ => $registration->$_() } (@all_reg_fields, 'editkey')),
      (map { 'round'.$_ => $rounds[$_ - 1] } (1 .. $tournament->rounds())),
    },
    nextaction => 'editregistrationresults',
  };
}

sub delete {
  my $self = shift;
  my $tournament_id = params()->{tournament_id};
  if(my $registration = $self->schema()->resultset('Registration')->find({editkey => params()->{editkey}})) {
    $registration->delete();
  }
  return redirect("/tournaments/$tournament_id/admin");
}

sub registerformresults {
  my $self = shift;
  my $tournament_id = params()->{tournament_id};
  my $tournament = $self->schema()->resultset('Tournament')->find($tournament_id);
  my %form = (
    _reg_form_as_hash(),
    map { 'round'.$_ => params()->{'round'.$_} || 0 } (1 .. $tournament->rounds())
  );
  foreach (@mandatory_reg_fields) {
    if(!$form{$_}) {
      return {
        tournament => { id => $tournament_id },
        tournament_obj => $tournament,
        form       => \%form,
        template   => 'tournament-registerform.tt',
      };
    }
  }

  my $database = $self->schema();
  my $registration = $database->resultset('Registration')->find({
    map { $_ => params()->{$_} } qw(tournament_id email given_name family_name)
  });

  my $return = {
    tournament => $tournament,
    template   => 'tournament-details.tt',
    registrants => [$tournament->people_to_show()],
  };

  if($registration) {
    # already registered
    return { %{$return}, message => 'alreadyregistered' };
  };

  # let's not use characters that mean something in URLs ...
  (my $editkey = md5_base64(rand().$$.Data::UUID->new()->create_str()))
    =~ s{/}{_}g;

  eval {
    $registration = $database->resultset('Registration')->create({
      (map { $_ => params()->{$_} } ('tournament_id', @mandatory_reg_fields)),
      show_on_site => (params()->{show_on_site} ? 1 : 0),
      bga_member   => (params()->{bga_member}   ? 1 : 0),
      notes        => (params()->{notes}        ? params()->{notes} : ''),
      (params()->{club} ? (club => params()->{club}) : ()),
      editkey => $editkey,
      rounds => join(',', map { params()->{'round'.$_} ? 1 : 0 } (1 .. $tournament->rounds())),
    });
    push @{$return->{registrants}}, $registration;
  };
  my $message = $@ ? 'regfailed' : 'registered';
  if($message eq 'registered') {
    my $msg = MIME::Lite->new(
      From    => $tournament->email(),
      To      => params()->{email},
      Cc      => $tournament->email(),
      Subject => $tournament->name(),
      Data    => "
Thankyou for registering for ".$tournament->name().".

Your registration details are below, please check that they are
correct.  You can edit them by visiting:

http://".config()->{hostname}.':'.config()->{port}."/tournaments/".$tournament->id()."/editregistration/$editkey

           Given name: ".params()->{given_name}."
          Family name: ".params()->{family_name}."
                Email: ".params()->{email}."
   Registration class: ".params()->{class}."
                 Club: ".params()->{club}."
              Country: ".params()->{country}."
                Grade: ".params()->{grade}."
                Notes: ".params()->{notes}."
      Show on website: ".(params()->{show_on_site} ? "Yes" : "No (but we wish you'd change your mind)")."
National assoc member: ".(params()->{bga_member} ? "Yes" : "No")."
")->send();
  }
  return { %{$return},
    message      => $message,
    registration => $registration,
  };
}

sub editregisterformresults {
  my $self = shift;
  my $tournament_id = params()->{tournament_id};
  my $tournament    = $self->schema()->resultset('Tournament')->find($tournament_id);
  my %form = (
    _reg_form_as_hash(), editkey => params()->{editkey},
    (map { 'round'.$_ => params()->{'round'.$_  || 0 } } (1 .. $tournament->rounds())),
  );

  foreach (@mandatory_reg_fields) {
    if(!$form{$_}) {
      return {
        tournament => { id => $tournament_id },
        tournament_obj => $tournament,
        form       => \%form,
        template   => 'tournament-registerform.tt',
        nextaction => 'editregistrationresults',
      };
    }
  }

  my $database = $self->schema();
  my $registration = $database->resultset('Registration')->find({ editkey => params()->{editkey} }); 

  my $return = {
    tournament => $tournament,
    template   => 'tournament-details.tt',
    registrants => [$tournament->people_to_show()],
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
  $registration->notes(params()->{notes} ? params()->{notes} : '');
  $registration->rounds(join(',', map { params()->{'round'.$_} ? 1 : 0 } (1 .. $tournament->rounds())));
  $registration->update();

  return { %{$return},
    message      => 'edited',
    registration => $registration,
    registrants  => [$tournament->people_to_show()],
  };
}

1;
