package Thunderhorse::Autoloadable;

use v5.40;
use Mooish::Base -standard, -role;

requires qw(_autoload_from);

# introduce DESTROY as a method so that it does not hit AUTOLOAD
sub DESTROY { }

# autoload the rest
sub AUTOLOAD ($self, @args)
{
	our $AUTOLOAD;

	state %methods;
	my $method = $methods{$AUTOLOAD} //= do {
		my $wanted = $AUTOLOAD =~ s{^(.+)::}{}r;
		my $bad_method = $1 =~ m/::SUPER$/;
		!$bad_method ? $wanted : undef;
	};

	state %autoloadable;
	my $source = $autoloadable{ref $self} //= do {
		my $is_object = length ref $self;
		$is_object ? $self->_autoload_from : undef;
	};

	die "no such method $AUTOLOAD"
		unless defined $method && defined $source;

	return $self->{$source}->$method(@args);
}

sub can ($self, $method)
{
	my $I_can = $self->SUPER::can($method);
	return $I_can if $I_can;

	if (ref $self) {
		my $source_can = $self->{$self->_autoload_from}->can($method);
		return $source_can;
	}

	return undef;
}

