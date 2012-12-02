package BGATournaments::Widget::Admin;

use strict;
use warnings;
use Dancer qw(:syntax);

use base qw(BGATournaments::Widget);

sub admin {
  my $self = shift;
  my $database = $self->schema();
  my $tournament_id = params()->{tournament_id};

  if(session('user_id') && $database->resultset('TournamentLogin')->find({
    tournament_id => $tournament_id,
    email         => session('user_id'),
  })) {
    my $tournament = $database->resultset('Tournament')->find($tournament_id);
    return {
      template   => 'tournament-details.tt',
      tournament => $tournament,
      registrants => [$tournament->registrants()->all()],
      admin_mode  => 1,
    }
  }

  # or if not logged in ...
  session('target_page', "/tournaments/$tournament_id/admin");
  return redirect('/login');
}

sub download {
  my $self = shift;
  my $database = $self->schema();
  my $tournament_id = params()->{tournament_id};

  my $data="ID\tFAMILY\tGIVEN\tGRADE\tCLUB\tCOUNTRY\tNOTE\n";
  my @registrants = $database->resultset('Tournament')->find($tournament_id)->registrants()->all();

  my $id = 0;
  foreach my $person (@registrants) {
    $id++;
    $data .= "$id\t";
    $data .= $person->family_name()."\t"; 
    $data .= $person->given_name()."\t"; 
    $data .= $person->grade()."\t"; 
    $data .= $person->club()."\t"; 
    $data .= $person->country()."\t"; 
    $data .= "tp: ".$person->to_pay()." (".$person->class()." reg at ".$person->registered_on()."); ";

    my @rounds_binary = split(/,/, $person->rounds());
    my @rounds_human = ();
    foreach my $round (1 .. $#rounds_binary + 1) {
      push @rounds_human, $round if($rounds_binary[$round - 1]);
    }
    my $rounds = '['.join(', ', @rounds_human).']';
    
    $data .= "rounds: $rounds; ";
    (my $notes = $person->notes()) =~ s/[\n\r]+/ /g;
    $data .= "notes: $notes";
    $data .= "\n";
  }

  return send_file(
    \$data,
    content_type => 'text/plain',
    filename     => "$tournament_id.txt",
  );
}

1;
