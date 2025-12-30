package Thunderhorse::Config;

use v5.40;
use Mooish::Base -standard;

use Path::Tiny qw(path);

extends 'Gears::Config';

has param 'config_dir' => (
	isa => Str,
	default => 'conf',
);

sub load_from_files ($self, $env)
{
	my $conf_dir = path($self->config_dir);
	return unless -d $conf_dir;

	my @extensions = map { $_->handled_extensions } $self->readers->@*;

	foreach my $base_name ('config', $env // ()) {
		foreach my $ext (@extensions) {
			my $file = $conf_dir->child("$base_name.$ext");
			$self->add(file => "$file")
				if -f $file;
		}
	}

	return;
}

