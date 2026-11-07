# Copyright James McCoy <jamessan@debian.org> 2013.
# Modifications copyright 2002 Julian Gilbey <jdg@debian.org>

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
# along with this program. If not, see <https://www.gnu.org/licenses/>.

package Devscripts::Compression;

use Dpkg::Compression qw(
  !compression_get_file_extension
  !compression_get_cmdline_compress
  !compression_get_cmdline_decompress
);
use Dpkg::IPC;
use Exporter qw(import);

our @EXPORT = (
    @Dpkg::Compression::EXPORT,
    qw(
      compression_get_file_extension
      compression_get_cmdline_compress
      compression_get_cmdline_decompress
      compression_guess_from_file
    ),
);

eval {
    Dpkg::Compression->VERSION(2.01);
    1;
} or do {
    # Ensure we have the compression getters, regardless of the version of
    # Dpkg::Compression to ease backporting.
    *{'Dpkg::Compression::compression_get_file_extension'} = sub {
        my $comp = shift;
        return compression_get_property($comp, 'file_ext');
    };
    *{'Dpkg::Compression::compression_get_cmdline_compress'} = sub {
        my $comp = shift;
        my @prog = @{ compression_get_property($comp, 'comp_prog') };
        push @prog, '-' . compression_get_property($comp, 'default_level');
        return @prog;
    };
    *{'Dpkg::Compression::compression_get_cmdline_decompress'} = sub {
        my $comp = shift;
        my @prog = @{ compression_get_property($comp, 'decomp_prog') };
        return @prog;
    };
};

# This can potentially be moved to Dpkg::Compression

my %mime2comp = (
    "application/x-gzip"       => "gzip",
    "application/gzip"         => "gzip",
    "application/x-bzip2"      => "bzip2",
    "application/bzip2  "      => "bzip2",
    "application/x-xz"         => "xz",
    "application/xz"           => "xz",
    "application/zip"          => "zip",
    "application/x-compress"   => "compress",
    "application/java-archive" => "zip",
    "application/x-tar"        => "tar",
    "application/zstd"         => "zst",
    "application/x-zstd"       => "zst",
);

sub compression_guess_from_file {
    my $filename = shift;
    my $mimetype;
    spawn(
        exec => ['file', '--dereference', '--brief', '--mime-type', $filename],
        to_string  => \$mimetype,
        wait_child => 1
    );
    chomp($mimetype);
    if (exists $mime2comp{$mimetype}) {
        return $mime2comp{$mimetype};
    } else {
        return;
    }
}

# comp_prog and default_level aren't provided because a) they aren't needed in
# devscripts and b) the Dpkg::Compression API isn't rich enough to support
# these as compressors
my %comp_properties = (
    compress => {
        file_ext    => 'Z',
        decomp_prog => ['uncompress'],
    },
    zip => {
        file_ext    => 'zip',
        decomp_prog => ['unzip'],
    },
    zst => {
        file_ext => 'zst',
        #comp_prog     => ['zstd'],
        decomp_prog   => ['unzstd'],
        default_level => 3,
    });

sub compression_get_file_extension {
    my $comp = shift;
    if (!exists $comp_properties{$comp}) {
        return Dpkg::Compression::compression_get_file_extension($comp);
    }
    return $comp_properties{$comp}{file_ext};
}

sub compression_get_cmdline_compress {
    my $comp = shift;
    if (!exists $comp_properties{$comp}) {
        return Dpkg::Compression::compression_get_cmdline_compress($comp);
    }
    return @{ $comp_properties{$comp}{comp_prog} };
}

sub compression_get_cmdline_decompress {
    my $comp = shift;
    if (!exists $comp_properties{$comp}) {
        return Dpkg::Compression::compression_get_cmdline_decompress($comp);
    }
    return @{ $comp_properties{$comp}{decomp_prog} };
}

1;
