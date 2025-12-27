package Thunderhorse::Context::Facade;

use v5.40;

use Mooish::Base -standard;

use Devel::StrictMode;

# use handles for fast access (autoloading is kind of slow)
has param 'context' => (
	(STRICT ? (isa => InstanceOf ['Thunderhorse::Context']) : ()),
	handles => [
		qw(
			app
			req
			res
		)
	],
);

# autoload the rest
sub AUTOLOAD ($self, @args)
{
	state %methods;
	our $AUTOLOAD;

	my $method = $methods{$AUTOLOAD} //= do {
		my $wanted = $AUTOLOAD =~ s{^.+::}{}r;
		return if $wanted eq 'DESTROY';
		$wanted;
	};

	# do not call context in package context
	die "no such method $method"
		unless ref $self;

	return $self->context->$method(@args);
}

sub can ($self, $method)
{
	# extra careful here, not to call context method in package context
	my $context_can = ref $self && $self->context->can($method);
	return $context_can if $context_can;
	return $self->SUPER::can($method);
}

