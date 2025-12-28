use v5.40;
use Benchmark::Dumb qw(cmpthese);

use Thunderhorse::Context;
use Thunderhorse::Context::Facade;

cmpthese 200.01, {
	raw => sub {
		my $ctx = Thunderhorse::Context->new(app => false, pagi => [{}, sub { }, sub { }]);

		# create facade anyway, so we don't bench the bless overhead
		my $facade = Thunderhorse::Context::Facade->new(context => $ctx);

		for (1 .. 100) {
			$ctx->match;
		}
	},
	autoload => sub {
		my $ctx = Thunderhorse::Context->new(app => false, pagi => [{}, sub { }, sub { }]);
		my $facade = Thunderhorse::Context::Facade->new(context => $ctx);

		for (1 .. 100) {
			$facade->match;
		}
	},
	delegation => sub {
		my $ctx = Thunderhorse::Context->new(app => false, pagi => [{}, sub { }, sub { }]);
		my $facade = Thunderhorse::Context::Facade->new(context => $ctx);

		for (1 .. 100) {
			$facade->app;
		}
	},
};

