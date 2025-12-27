package Thunderhorse::Context::Facade;

use v5.40;

# fast access (autoloading is kind of slow)
sub app { $_[0]->$*->app }
sub req { $_[0]->$*->req }
sub res { $_[0]->$*->res }

# autoload the rest
sub AUTOLOAD ($ctx_ref, @args)
{
	state %methods;
	our $AUTOLOAD;

	my $method = $methods{$AUTOLOAD} //= do {
		my $wanted = $AUTOLOAD =~ s{^.+::}{}r;
		return if $wanted eq 'DESTROY';
		$wanted;
	};

	return $ctx_ref->$*->$method(@args);
}

sub can ($ctx_ref, $method)
{
	my $context_can = $ctx_ref->$*->can($method);
	return $context_can if $context_can;
	return $ctx_ref->SUPER::can($method);
}

