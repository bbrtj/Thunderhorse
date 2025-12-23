use Test2::V1 -ipP;
use Thunderhorse;
use PAGI::Test;

################################################################################
# This tests whether Thunderhorse basic app works
################################################################################

package BasicApp {
	use v5.40;
	use Mooish::Base -standard;

	extends 'Thunderhorse::App';

	sub build ($self)
	{
		$self->router->add(
			'/basic/:ph' => {
				to => sub ($self, $context, $ph) {
					my $self_class = ref $self;
					my $context_class = ref $context;

					return "$self_class;$context_class;$ph";
				}
			}
		);
	}
};

my $app = BasicApp->new->run;

subtest 'should route to a valid location' => sub {
	my $test = PAGI::Test->new(app => $app);
	my $res = $test->get('/basic/placeholder')->get;

	my @events = $res->events;
	ok @events > 0, 'Events captured';

	my ($start) = grep { $_->{type} eq 'http.response.start' } @events;
	ok $start, 'Start event captured';
	is $start->{status}, 200, 'Status in start event';

	my ($body) = grep { $_->{type} eq 'http.response.body' } @events;
	ok $body, 'Body event captured';
	is $body->{body}, 'BasicApp;Thunderhorse::Context;placeholder', 'Body in event';
};

subtest 'should route to 404' => sub {
	my $test = PAGI::Test->new(app => $app);
	my $res = $test->get('/basic')->get;

	my @events = $res->events;
	ok @events > 0, 'Events captured';

	my ($start) = grep { $_->{type} eq 'http.response.start' } @events;
	ok $start, 'Start event captured';
	is $start->{status}, 404, 'Status in start event';

	my ($body) = grep { $_->{type} eq 'http.response.body' } @events;
	ok $body, 'Body event captured';
	is $body->{body}, 'Not Found', 'Body ok';
};

done_testing;

