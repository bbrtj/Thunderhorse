package Thunderhorse::Controller;

use v5.40;
use Mooish::Base -standard;

extends 'Gears::Controller';
with 'Thunderhorse::Routable';

sub router ($self)
{
	return $self->app->router;
}

