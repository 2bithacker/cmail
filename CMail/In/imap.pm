### CMail::In::imap
# module for checking for messages in imap mailboxes
package CMail::In::imap;

use strict;

BEGIN {
	use CMail::In::Base;
	use vars qw($VERSION @ISA);

	$VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

	@ISA = qw( CMail::In::Base );
}

use IO::Socket;

use vars qw(%connections %cmdnum);

# For keeping the connection cache, so we don't have to reconnect multiple
# times if we're checking multiple mailboxes on the same IMAP server
%connections = ();

# For keeping the current command number of different imap connections
%cmdnum = ();

# methods
sub count {
	my $self = shift;

	my($user,$pass,$host,$port,$path) = $self->parse_uri;
	$self->{user} = $user;
	$self->{host} = $host;
	$self->{port} = $port;
	my $verbose = $self->{verbose};

	$path =~ s!^/!!;	# get rid of starting slash
	$path = 'INBOX' if ( $path =~ /^\s*$/ );

	warn "imap: Getting socket for $host.\n" if $verbose > 1;
	my $socket = $self->connect_login($host,$port,$user,$pass);

	# Send STAT
	warn "imap: Sending STATUS $path (MESSAGES UNSEEN) to server.\n"
		if $verbose > 1;
	my $resp = send_cmd($socket,"STATUS $path (MESSAGES UNSEEN)");
	return comm_error($resp) unless $resp =~ /\(MESSAGES (\d+) UNSEEN (\d+)\)/;
	warn "imap: Server said there are $1 messages, $2 new.\n" if $verbose;

	return($1,$2);
}

# internal methods

# connect_login($host,$port,$user,$pass) - opens a socket to the given
# host and port and returns it. If someone wants to implement SSL, I
# suggest overloading just this function, if that's all that's required.
sub connect_login {
	my $self = shift;
	my $host = shift;
	my $port = shift || '143';
	my $user = shift;
	my $pass = shift;

	my $id = "$host:$port:$user";

	if (defined $connections{$id}) {
		$connections{$id}->{usage}++;
		return $connections{$id}->{socket};
	}

	my $socket = IO::Socket::INET->new(
		PeerAddr	=>      $host,
		PeerPort	=>      $port,
		Proto		=>      'tcp',
	);

	if ( not defined $socket ) {
		die "imap: couldn't open socket to $host:$port: $!\n";
	}

	$connections{$id} = {
		'socket'	=> $socket,
		'usage'		=> 1,
	};
	my $answer = send_cmd($socket,"LOGIN $user $pass");
	if ( $answer =~ /BAD|NO/ ) {
		die "imap: couldn't login to $host: $answer\n";
	}

	return $socket;
}

sub DESTROY {
	my $self = shift;

	my $host = $self->{host};
	my $port = $self->{port} || 143;
	my $user = $self->{user};

	my $id = "$host:$port:$user";

	if ( defined $connections{$id} ) {
		$connections{$id}->{usage}--;

		if ($connections{$id}->{usage} < 1) {
			my $socket = $connections{$id}->{socket};
			send_cmd($socket,"LOGOUT");
			$socket->close;
		}
	}
}

sub send_cmd {
	my $socket = shift;
	my $command = shift;

	$cmdnum{$socket}++;
	my $num = $cmdnum{$socket};

	#warn "C: 'a$num $command'\n";

	$socket->print("a$num $command\r\n");

	my $resp = '';

	while ( $resp !~ /a$num/ ) {
		my $line = $socket->getline;
		$resp .= $line;

		$line =~ s/\s+$//;
		#warn "S: '$line'\n";
	}

	return $resp;
}

sub comm_error {
	my $response = shift;

	$response =~ s/\s+$//;

	die "imap: server responded with negative '$response'\n";

	return;
}

1;
