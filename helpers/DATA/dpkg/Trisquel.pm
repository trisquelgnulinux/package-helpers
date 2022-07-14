# Copyright © 2008 Ian Jackson <ijackson@chiark.greenend.org.uk>
# Copyright © 2008 Canonical, Ltd.
#   written by Colin Watson <cjwatson@ubuntu.com>
# Copyright © 2008 James Westby <jw+debian@jameswestby.net>
# Copyright © 2009 Raphaël Hertzog <hertzog@debian.org>
# Copyright © 2022 Ruben Rodriguez <ruben@trisquel.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

package Dpkg::Vendor::Trisquel;

use strict;
use warnings;

our $VERSION = '0.01';

use Dpkg::ErrorHandling;
use Dpkg::Gettext;
use Dpkg::Control::Types;

use parent qw(Dpkg::Vendor::Debian);

=encoding utf8

=head1 NAME

Dpkg::Vendor::Trisquel - Trisquel vendor class

=head1 DESCRIPTION

This vendor class customizes the behaviour of dpkg scripts for Trisquel
specific behavior and policies.

=cut

sub run_hook {
    my ($self, $hook, @params) = @_;

    if ($hook eq 'package-keyrings') {
        return ($self->SUPER::run_hook($hook),
                '/usr/share/keyrings/trisquel-archive-keyring.gpg');
    } elsif ($hook eq 'archive-keyrings') {
        return ($self->SUPER::run_hook($hook),
                '/usr/share/keyrings/trisquel-archive-keyring.gpg');
    } elsif ($hook eq 'archive-keyrings-historic') {
        return ($self->SUPER::run_hook($hook),
                '/usr/share/keyrings/trisquel-archive-removed-keys.gpg');
    } elsif ($hook eq 'update-buildflags') {
	my $flags = shift @params;

        # Run the Debian hook to add hardening flags
        $self->SUPER::run_hook($hook, $flags);

        require Dpkg::BuildOptions;

	my $build_opts = Dpkg::BuildOptions->new();

	if (!$build_opts->has('noopt')) {
            require Dpkg::Arch;

            my $arch = Dpkg::Arch::get_host_arch();
            if (Dpkg::Arch::debarch_eq($arch, 'ppc64el')) {
		for my $flag (qw(CFLAGS CXXFLAGS OBJCFLAGS OBJCXXFLAGS GCJFLAGS
		                 FFLAGS FCFLAGS)) {
                    my $value = $flags->get($flag);
                    $value =~ s/-O[0-9]/-O3/;
                    $flags->set($flag, $value);
		}
	    }
	}
	# Per https://wiki.ubuntu.com/DistCompilerFlags
        $flags->prepend('LDFLAGS', '-Wl,-Bsymbolic-functions');
    } else {
        return $self->SUPER::run_hook($hook, @params);
    }

    # Default return value for unknown/unimplemented hooks
    return;
}

=head1 CHANGES

=head2 Version 0.xx

This is a private module.

=cut

1;
