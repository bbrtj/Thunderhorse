package Thunderhorse::Response;

use v5.40;
use Mooish::Base -standard;

use Gears::X;

extends 'PAGI::Response';
with 'Thunderhorse::Message';

sub FOREIGNBUILDARGS ($class, %args)
{
	Gears::X->raise('no context for response')
		unless $args{context};

	return $args{context}->pagi->@[2];
}

sub update ($self)
{
	my $pagi = $self->context->pagi;
	$self->{send} = $pagi->[2];
}

sub sent ($self)
{
	return !!$self->{_sent};
}

