### CMail::In::pop3
# module for checking for messages in pop3 mailboxes
package CMail::In::pop3;

use strict;

BEGIN {
	use CMail::In::Base;
	use vars qw($VERSION @ISA);

	$VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

	@ISA = qw( CMail::In::Base );
}

use IO::Socket;

# methods
sub count {
	my $self = shift;

	my($user,$pass,$host,$port) = $self->parse_uri;
	my $verbose = $self->{verbose};

	warn "pop3: Connecting to $host.\n" if $verbose > 1;
	my $socket = $self->connect($host,$port);
	my $resp = '';

	# Get greeting from server
	$resp = $socket->getline;
	return comm_error($resp) unless $resp =~ /^\+OK/;

	# Send USER
	warn "pop3: Sending 'USER $user' to server.\n" if $verbose > 1;
	$socket->print("USER $user\r\n");
	$resp = $socket->getline;
	return comm_error($resp) unless $resp =~ /^\+OK/;

	# Send PASS
	warn "pop3: Sending 'PASS $pass' to server.\n" if $verbose > 1;
	$socket->print("PASS $pass\r\n");
	$resp = $socket->getline;
	return comm_error($resp) unless $resp =~ /^\+OK/;

	# Send STAT
	warn "pop3: Sending 'STAT' to server.\n" if $verbose > 1;
	$socket->print("STAT\r\n");
	$resp = $socket->getline;
	return comm_error($resp) unless $resp =~ /^\+OK\s+(\d+)\s+/;
	warn "pop3: Server said there are $1 messages.\n" if $verbose;
	my $count = $1;

	# Send QUIT
	warn "pop3: Sending 'QUIT' to server.\n" if $verbose > 1;
	$socket->print("QUIT\r\n");
	$resp = $socket->getline;
	return comm_error($resp) unless $resp =~ /^\+OK/;

	# Close socket.
	$socket->close;

	return($count,0);
}

# internal methods

# connect($host,$port) - opens a socket to the given host and port and
#  returns it. If someone wants to implement SSL, I suggest overloading
#  just this function, if that's all that's required.
sub connect {
	my $self = shift;
	my $host = shift;
	my $port = shift || '110';

	my $socket = IO::Socket::INET->new(
		PeerAddr	=>	$host,
		PeerPort	=>	$port,
		Proto		=>	'tcp',
	);

	if ( not defined $socket ) {
		die "pop3: couldn't open socket to $host:$port: $!\n";
	}

	return $socket;
}

sub comm_error {
	my $response = shift;

	$response =~ s/\s+$//;

	die "pop3: server responded with negative '$response'\n";

	return;
}

1;
