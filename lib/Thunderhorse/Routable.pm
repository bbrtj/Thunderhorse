package Thunderhorse::Routable;

use v5.40;
use Mooish::Base -standard, -role;

around router => sub ($orig, $self) {
	my $router = $self->$orig;
	$router->set_controller($self);
	return $router;
};

