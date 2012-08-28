### CMail::In::file
# backwards compatibily module, just provides mbox under a different name
package CMail::In::file;

use strict;

BEGIN {
	use CMail::In::mbox;
	use vars qw($VERSION @ISA);

	$VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

	@ISA = qw( CMail::In::mbox );
}

warn "Using file compatibility module. Please change configs to use mbox.\n";

1;
