package Thunderhorse::Routable;

use v5.40;
use Mooish::Base -standard, -role;

use Thunderhorse::Context::Facade;

requires qw(
	app
);

sub make_facade ($self, $ctx)
{
	return Thunderhorse::Context::Facade->new(context => $ctx);
}

around router => sub ($orig, $self) {
	my $router = $self->$orig;
	$router->set_controller($self);
	return $router;
};

