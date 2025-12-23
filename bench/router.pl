use v5.40;
use Benchmark::Dumb qw(cmpthese);

use Kelp::Routes;
use Thunderhorse::App;
use Thunderhorse::Router;

package NullCache {
	sub new { bless {}, $_[0] }
	sub get { undef }
	sub set { }
	sub clear { }
}

package FullCache {
	sub new { bless {store => {}}, $_[0] }
	sub get { return $_[0]{store}{$_[1]} }
	sub set { return $_[0]{store}{$_[1]} = $_[2] }
	sub clear { $_[0]{store}->%* = () }
}

package THNullCache {
	use Mooish::Base -standard;
	extends 'NullCache';
	with 'Thunderhorse::Router::SpecializedCache';
}

package THFullCache {
	use Mooish::Base -standard;
	extends 'FullCache';
	with 'Thunderhorse::Router::SpecializedCache';
}

my $cache = shift();
my $k_cache = $cache ? FullCache->new : NullCache->new;
my $th_cache = $cache ? THFullCache->new : THNullCache->new;

my $th_a = Thunderhorse::App->new(
	router => Thunderhorse::Router->new(
		# ($cache ? (cache => $th_cache) : ())
		cache => $th_cache,
	),
);
my $th_r = $th_a->router;
$th_r->add('/test' => {to => sub { }})->add('/:sth' => {to => sub { }});
my $th_admin = $th_r->add('/admin' => {to => sub { }});
for (1 .. 20) {
	$th_admin->add("/route$_" => {to => sub { }});
}

my $k_r = Kelp::Routes->new(cache => $k_cache);
$k_r->add('/test' => {to => sub { }, bridge => 1})->add('/:sth' => {to => sub { }});
my $k_admin = $k_r->add('/admin' => {to => sub { }, bridge => 1});
for (1 .. 20) {
	$k_admin->add("/route$_" => {to => sub { }});
}

# use Data::Dumper;
# print Dumper($k_r->match('/test/test2'));
# print Dumper($th_r->match('/test/test2'));

cmpthese 200.01, {
	thunderhorse => sub { $th_r->flat_match('/test/test2') },
	kelp => sub { $k_r->match('/test/test2') },
};

