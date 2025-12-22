package HelloApp;

use v5.40;
use Mooish::Base -standard;

extends 'Thunderhorse::App';

sub build ($self)
{
	my $r = $self->router;

	$r->add(
		'/hello/?msg' => {
			to => 'print_message',
			defaults => {
				msg => 'world',
			},
		}
	);
}

sub print_message ($self, $context, $msg)
{
	return "Hello, $msg!";
}

