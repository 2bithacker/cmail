### CMail::In::Base
# just provides a couple base methods for mailbox readers
package CMail::In::Base;
use Carp;

=pod

=head1 NAME

CMail::In::Base - base class for cmail input modules

=head1 DESCRIPTION

This module serves as a base class to all other cmail input modules. If you
are intending to write your own input module, it is suggested that you make
it a sub-class of this one. Below are details on the parts of this module,
what you should leave alone, what you should override, and what is available
to help you out.

=head1 CONSTRUCTOR

The constructor for CMail::In::Base is fairly simple, and does little more
than setup the object and call the config method. I'd suggest not overloading
the constructor, and instead overloading the config method.

=cut

# constructor
sub new {
	my $proto	= shift;
	my $class	= ref($proto) || $proto;
	my $self	= {};
	bless($self,$class);

	$self->config(@_);

	return $self;
}

=pod

=head1 METHODS TO OVERLOAD

These are the methods that should be overloaded when making a new module.
Some of them must be overloaded, others have a reasonable default action.

=over 4

=item $obj->config(%conf)

This is called by the constructor after creating the object. When it is
called, the object is empty. It's job is to fill the object with whatever
is needed. The default method just takes %conf and loads it into $obj
(which is a hash ref.)

=cut

sub config {
	my $self = shift;
	my %info = @_;

	foreach my $key ( keys %info ) {
		$self->{$key} = $info{$key};
	}

	return;
}

=pod

=item $obj->count()

This is the method that does the actual counting of the mailbox. It B<must>
be overloaded, or else the program will fail. It should return an array
of two elements, the first being a total message count, and the second being
a count of new messages. If you cannot determine how many messages are new,
as is the case with POP3, just return 0 (zero).

=cut

sub count {
	croak "Someone forgot to overload their count method.";
}

=pod

=back

=head1 UTILITY METHODS

These methods are here to provide an easy way to do some common tasks. They
should not be overloaded.

=over 4

=item $obj->parse_uri()

Parses out and returns the parts of the URI from the mailbox's config. This
assumes the URI has been loaded into $obj->{uri} (the default if you didn't
overload the constructor.) In string context, it returns only the path
information, which is useful for local mailboxes. In array context, it returns
an array of ($user,$password,$host,$port,$path). If any part is missing, it
will be undef.

=cut

# internal methods

# parse_uri - Parses out and returns the parts of the uri from the object's
#	config. In string context, return the path, in array context, returns
#	($user,$pass,$host,$port,$path)
sub parse_uri {
	my $self = shift;
	my $uri	= $self->{uri};

	if (wantarray) {	# do full extraction
		my @parts = ($uri =~ m{://([^:]+:[^@]+@)?([^/:]+)?(:\d+)?(/.*)?})
			or return undef;

		my($user,$pass) = ($parts[0] =~ /^(.*):(.*)\@$/);
		my $host = $parts[1];
		my $port = $parts[2];	$port =~ s/[^0-9]//g;
		my $path = $parts[3];

		return($user,$pass,$host,$port,$path);
	} else {			# do quick path extraction
		$uri =~ m{://[^/]*(/.*)} or return undef;
		my $path = $1;
		return $path;
	}
}

=pod

=back

=head1 AUTHOR

Chip Marshall <chip@chocobo.cx> http://www.chocobo.cx/chip/

=cut

1;
