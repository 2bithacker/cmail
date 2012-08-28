### CMail::Out::plain
# module for displaying count in plain text
package CMail::Out::plain;

use strict;

BEGIN {
	use CMail::Out::Base;
	use vars qw($VERSION @ISA);

	$VERSION = do { my @r = (q$Revision: 1.2 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

	@ISA = qw( CMail::Out::Base );
}

# methods
sub init {
	my $self		= shift;
	my %config		= @_;

	my $verbose		= $config{'verbose'};
	my $mailboxes	= $config{'mailboxes'};

	# Find the box with the longest name, for later formatting
	my $maxlength = 0;
	foreach my $mailbox ( @$mailboxes ) {
		my $length = length( $mailbox->{name} );
		$maxlength = $length if ( $length > $maxlength );
	}

	$self->{ max_name_len } = $maxlength;
	$self->{ verbose } = $verbose;

	warn "Longest name length is $maxlength.\n" if $verbose > 1;

	return;
}

sub display {
	my $self	= shift;
	my $mailbox	= shift;
	my $total	= shift;
	my $new		= shift;

	return unless ( $total > 0 );

	my $name	= $mailbox->{name};
	my $max		= $self->{ max_name_len };
	$max += 3;	# cause I think it looks better

	printf("%${max}s %4d message%s", $name, $total, (($total > 1)?'s':' ') );

	if ( $new > 0 ) {
		printf(" (%d new)", $new);
	}

	printf("\n");

	return;
}

1;
