### CMail::In::maildir
# module for checking for messages in maildir mailboxes
package CMail::In::maildir;

use strict;

BEGIN {
	use CMail::In::Base;
	use vars qw($VERSION @ISA);

	$VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

	@ISA = qw( CMail::In::Base );
}

# methods
sub count {
	my $self = shift;

	my $basedir = $self->parse_uri;
	$basedir =~ s/\/$//;	# get rid of trailing slash

	my $new = $self->check_maildir("$basedir/new");
	my $old = $self->check_maildir("$basedir/cur");
	my $total = $new + $old;

	return($total,$new);
}

# internal methods
sub check_maildir {
	my $self	= shift;
	my $dir		= shift;
	my $verbose	= $self->{verbose};

	my $count 	= 0;

	warn "maildir: Opening '$dir' and counting messages.\n" if $verbose;

	opendir(DIR, $dir) or die "Can't opendir $dir: $!\n";
	grep { /^[^.]/ && $count++ } readdir(DIR);
	closedir DIR;

	return $count;
}

1;
