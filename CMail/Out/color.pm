### CMail::Out::color
# module for displaying count in ANSI colored text
# Original color code was contributed by Ben April (ben@jlc.net)
package CMail::Out::color;

use strict;

BEGIN {
	use CMail::Out::plain;
	use vars qw($VERSION @ISA);

	$VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

	@ISA = qw( CMail::Out::plain );
}

use Term::ANSIColor;

# methods
sub display {
	my $self	= shift;
	my $mailbox	= shift;
	my $total	= shift;
	my $new		= shift;

	return unless ( $total > 0 );

	print color $mailbox->{option};
	$self->SUPER::display($mailbox,$total,$new);
	print color 'reset';

	return;
}

1;
