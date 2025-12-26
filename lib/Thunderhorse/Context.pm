package Thunderhorse::Context;

use v5.40;
use Mooish::Base -standard;

use Devel::StrictMode;

use Thunderhorse::Request;
use Thunderhorse::Response;

extends 'Gears::Context';

has param 'pagi' => (
	(STRICT ? (isa => Tuple [HashRef, CodeRef, CodeRef]) : ()),
	writer => -hidden,
);

has field 'match' => (
	(STRICT ? (isa => InstanceOf ['Gears::Router::Match']) : ()),
	writer => 1,
);

has field 'req' => (
	(STRICT ? (isa => InstanceOf ['Thunderhorse::Request']) : ()),
	default => sub ($self) { Thunderhorse::Request->new(context => $self) },
);

has field 'res' => (
	(STRICT ? (isa => InstanceOf ['Thunderhorse::Response']) : ()),
	default => sub ($self) { Thunderhorse::Response->new(context => $self) },
);

has field '_consumed' => (
	(STRICT ? (isa => Bool) : ()),
	writer => -public,
	default => false,
);

sub set_pagi ($self, $new)
{
	$self->_set_pagi($new);
	$self->req->update;
	$self->res->update;
}

sub scope ($self)
{
	return $self->pagi->[0];
}

sub receiver ($self)
{
	return $self->pagi->[1];
}

sub sender ($self)
{
	return $self->pagi->[2];
}

sub is_consumed ($self)
{
	return $self->_consumed || $self->res->is_sent;
}

