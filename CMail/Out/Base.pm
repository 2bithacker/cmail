### CMail::Out::Base
# just provides a couple base methods for display modules
package CMail::Out::Base;
use Carp;

=pod

=head1 NAME

CMail::Out::Base - base class for cmail output modules

=head1 DESCRIPTION

This module serves as a base class to all other cmail output modules. If you
are intending to write your own output module, it is suggested that you make
it a sub-class of this one. Below are details on the parts of this module,
what you should leave alone, what you should override, and what is available
to help you out.

=head1 CONSTRUCTOR

The constructor for CMail::Out::Base creates the object and calls the init
method on it, and not much else. If you want to do something at creation time,
I'd suggest putting it in init, not in the constructor.

=cut

sub new {
	my $proto	= shift;
	my $class	= ref($proto) || $proto;
	my $self	= {};
	bless($self,$class);

	$self->init(@_);

	return $self;
}

=pod

=head1 METHODS TO OVERLOAD

These are the methods that should be overloaded when making a new module.
Some of them must be overloaded, others have a reasonable default action.

=over 4

=item $obj->init(%conf)

This is called by the constructor after creating the object. When it is
called, the object is empty. It's job is to fill the object with whatever
is needed. The default just takes %conf and loads it into $obj (which is
a hash ref.)

=cut

sub init {
	my $self		= shift;
	my %config		= @_;

	$self->{verbose} = $config{verbose};

	return;
}

=pod

=item $obj->display($mailbox,$total,$new)

This is called once for each mailbox to be displayed. The first argument
is a CMail::In object. It should be a hashref with a 'name' key, holding
the descriptive name for the mailbox. Also, there should be an 'option'
key, which holds the display options. Options follow no specific form.
The second and third arguments are the total message count and the new
message count, respectively. This B<must> be overloaded in order for the
program to work.

=cut

sub display {
	croak "Someone forgot to overload their display method.";
}

=pod

=back

=head1 AUTHOR

Chip Marshall <chip@chocobo.cx> http://www.chocobo.cx/chip/

=cut

1;
