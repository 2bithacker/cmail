### CMail::In::mbox
# module for checking for messages in mbox mailboxes
package CMail::In::mbox;

use strict;

BEGIN {
	use CMail::In::Base;
	use vars qw($VERSION @ISA);

	$VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

	@ISA = qw( CMail::In::Base );
}

# methods
sub count {
	my $self = shift;
	my $file = $self->parse_uri;
	my $verbose = $self->{verbose};

	my $total	= 0;
	my $new		= 0;
	my $old		= 0;

	# First, save the access time, so we can put it back later
	# so that MUAs and biffs that rely on it will still properly
	# detect new mail. (Contributed by David McNett)
	my $atime = ( stat $file )[8];
	warn "mbox: saving access time of $atime\n" if $verbose > 1;

	# Now open the file and check for messages
	warn "mbox: Opening '$file' and counting messages.\n" if $verbose;
	if ( not open(MBOX, $file) ) {
		warn "mbox: can't open $file: $!" if $verbose;
		return(0,0);
	}
	
	$total = grep {
		$old++ if /^Status:.*O/;	# Check for old message flag

		# This regex finds the first line of a message
		/^From .* [MTWFS][a-z]{2} [A-Z][a-z]{2} [ 0-9]{2} [0-9:]{8} [0-9]{4}/;
	} <MBOX>;

	close MBOX;

	$new = $total - $old;

	# Restore atime of file
	my $modtime = ( stat $file )[9];
	utime $atime, $modtime, $file;
	warn "mbox: restored atime $atime to $file\n" if $verbose > 1;

	return ( $total, $new );
}

1;
