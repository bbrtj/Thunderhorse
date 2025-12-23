package Thunderhorse;

##################################
# ~~~~~~~~~~~~ Ride ~~~~~~~~~~~~ #
# ~~~~~~~~~~~~ Ride ~~~~~~~~~~~~ #
# ~~~~~~~~~~~~ Ride ~~~~~~~~~~~~ #
# ~~~~~~~~~~~~ Ride ~~~~~~~~~~~~ #
# ~~~~~~~~ Thunderhorse ~~~~~~~~ #
# ~~~~~~~~ Thunderhorse ~~~~~~~~ #
# ~~~~~~~~ Thunderhorse ~~~~~~~~ #
# ~~~~~~~~ Thunderhorse ~~~~~~~~ #
# ~~~~~~~~~~~ Revenge ~~~~~~~~~~ #
# ~~~~~~~~~~~ Revenge ~~~~~~~~~~ #
# ~~~~~~~~~~~ Revenge ~~~~~~~~~~ #
##################################

use v5.40;
use Exporter 'import';

use Future::AsyncAwait;
use Gears::X;

our @EXPORT_OK = qw(pagify);

# TODO: cache this
sub pagify ($location, $matched)
{
	my $dest = $location->get_destination;
	if ($location->pagi) {
		# TODO: adjust PAGI (like Kelp did to PSGI)
		return async sub ($scope, @args) {
			my $res = await $dest->($scope, @args);
			$scope->{thunderhorse}{context}->res->sent(true);

			return $res;
		}
	}
	else {
		return async sub ($scope, $receive, $send) {
			Gears::X->raise('bad PAGI execution chain, not a thunderhorse app')
				unless exists $scope->{thunderhorse};

			my $context = $scope->{thunderhorse}{context};
			$context->set_pagi([$scope, $receive, $send]);

			my $res = $context->res;
			try {
				my $result = $dest->($location->controller, $context, $matched->@*);
				$result = await $result
					if $result isa 'Future';

				if (defined $result && !$res->sent) {
					# TODO: result should be an array? (status, content_type, content)
					await $res->status(200)->html($result);
				}
			}
			catch ($ex) {
				die $ex unless $ex isa 'Gears::X::HTTP';
				# TODO: proper message
				await $res->status($ex->status)->text('Error')
				# TODO: log $ex->message
			}
		};
	}
}

1;

__END__

=head1 NAME

Thunderhorse - A no-compromises brutally-good web framework

=head1 SYNOPSIS

	use Thunderhorse;

	# do something

=head1 DESCRIPTION

This module lets you blah blah blah.

=head1 SEE ALSO

L<Some::Module>

=head1 AUTHOR

Bartosz Jarzyna E<lt>bbrtj.pro@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 by Bartosz Jarzyna

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

