package Thunderhorse::Routable;

use v5.40;
use Mooish::Base -standard, -role;

use Thunderhorse::Context::Facade;

requires qw(
	app
);

sub facade_class
{
	return 'Thunderhorse::Context::Facade';
}

sub make_facade ($self, $ctx)
{
	return bless \$ctx, $self->facade_class;
}

around router => sub ($orig, $self) {
	my $router = $self->$orig;
	$router->set_controller($self);
	return $router;
};

