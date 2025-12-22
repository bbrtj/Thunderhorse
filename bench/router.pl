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

my $cache_class = shift() ? 'FullCache' : 'NullCache';

my $th_a = Thunderhorse::App->new(router => Thunderhorse::Router->new(cache => $cache_class->new));
my $th_r = $th_a->router;
$th_r->add('/test' => {to => sub { }})->add('/:sth' => {to => sub { }});
$th_r->add('/x1' => {to => sub { }})->add('/x2' => {to => sub { }});
$th_r->add('/y1' => {to => sub { }})->add('/y2' => {to => sub { }});
$th_r->add('/z1' => {to => sub { }})->add('/z2' => {to => sub { }});

my $k_r = Kelp::Routes->new(cache => $cache_class->new);
$k_r->add('/test' => {to => sub { }, bridge => 1})->add('/:sth' => {to => sub { }});
$k_r->add('/x1' => {to => sub { }, bridge => 1})->add('/x2' => {to => sub { }});
$k_r->add('/y1' => {to => sub { }, bridge => 1})->add('/y2' => {to => sub { }});
$k_r->add('/z1' => {to => sub { }, bridge => 1})->add('/z2' => {to => sub { }});

# use Data::Dumper;

# print Dumper($th_r->match('/test/test2'));
# print Dumper($k_r->match('/test/test2'));

cmpthese 300.01, {
	thunderhorse => sub { $th_r->flat_match('/test/test2') },
	kelp => sub { $k_r->match('/test/test2') },
};

