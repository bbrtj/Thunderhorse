use v5.40;
use Benchmark::Dumb qw(cmpthese);

use Thunderhorse::Context;
use Thunderhorse::Context::Facade;

cmpthese 200.01, {
	context => sub {
		my $ctx = Thunderhorse::Context->new(app => false, pagi => [{}, sub { }, sub { }]);
		$ctx->consume;
		$ctx->is_consumed;

		# create facade anyway, so we don't bench the bless overhead
		my $facade = Thunderhorse::Context::Facade->new(context => $ctx);
	},
	facade => sub {
		my $ctx = Thunderhorse::Context->new(app => false, pagi => [{}, sub { }, sub { }]);
		my $facade = Thunderhorse::Context::Facade->new(context => $ctx);
		$facade->consume;
		$facade->is_consumed;
	},
};

