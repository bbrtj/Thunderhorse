use Test2::V1 -ipP;
use Thunderhorse::Test;

################################################################################
# This tests Thunderhorse edge cases
################################################################################

package EdgeApp {
	use v5.40;
	use Mooish::Base -standard;

	extends 'Thunderhorse::App';

	sub build ($self)
	{
		my $r = $self->router;

		# it is possible to have multiple locations, and the first one which
		# renders stops the execution chain
		$r->add('/multi' => {to => sub { return undef }});
		$r->add('/multi');
		$r->add('/multi' => {to => sub { return 'this gets rendered' }});
		$r->add('/multi' => {to => sub { return 'this does not rendered' }});

		# normally routes are returned in the order of declaration and nesting,
		# however it is possible to specify order explicitly (lower gets
		# executed faster). Routes which are not ordered should stay in the
		# order of declaration
		$r->add('/order' => {to => sub { shift->stash_and_return(@_, 'first declared') }});
		$r->add('/order' => {to => sub { shift->stash_and_return(@_, 'positive order') }, order => 1});
		$r->add('/order' => {to => sub { shift->stash_and_return(@_, 'after all') }, order => 1});
		my $b = $r->add('/order' => {to => sub { shift->stash_and_return(@_, 'bridge') }});
		$b->add('' => {to => sub { shift->stash_and_return(@_, 'first bridged') }});
		$b->add('' => {to => sub { shift->stash_and_return(@_, 'second bridged') }, order => -1});
		$b->add('' => {to => sub { shift->stash_and_return(@_, 'third bridged') }});
		$r->add('/order' => {to => sub { shift->stash_and_return(@_, 'before bridge') }, order => -1});
		$r->add('/order' => {to => sub { shift->stash_and_return(@_, 'last declared') }});
		$r->add('/order' => {to => 'print_stash', order => 9});

		# routes with normally catch all methods, but it is possible
		# to specify a single method in router too
		$r->add('/any_method' => {to => 'print_method'});
		$r->add('/only_post' => {to => 'print_method', method => 'POST'});
	}

	sub stash_and_return ($self, $ctx, $msg)
	{
		push $ctx->stash->{order}->@*, $msg;
		return undef;
	}

	sub print_stash ($self, $ctx)
	{
		return join ' -> ', $ctx->stash->{order}->@*;
	}

	sub print_method ($self, $ctx)
	{
		return $ctx->req->method;
	}
};

my $t = Thunderhorse::Test->new(app => EdgeApp->new);

subtest 'should handle multiple locations for the same route' => sub {
	$t->request('/multi')
		->status_is(200)
		->body_is('this gets rendered')
		;
};

subtest 'should respect route ordering' => sub {
	my @order = (
		'before bridge',
		'first declared',
		'bridge',
		'second bridged',
		'first bridged',
		'third bridged',
		'last declared',
		'positive order',
		'after all',
	);

	$t->request('/order')
		->status_is(200)
		->body_is(join ' -> ', @order)
		;
};

subtest 'should handle method-specific routing' => sub {
	$t->request('/any_method', method => 'GET')
		->status_is(200)
		->body_is('GET')
		;

	$t->request('/any_method', method => 'POST')
		->status_is(200)
		->body_is('POST')
		;

	$t->request('/only_post', method => 'GET')
		->status_is(404)
		;

	$t->request('/only_post', method => 'POST')
		->status_is(200)
		->body_is('POST')
		;
};

done_testing;

