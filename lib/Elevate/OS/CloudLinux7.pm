package Elevate::OS::CloudLinux7;

=encoding utf-8

=head1 NAME

Elevate::OS::CloudLinux7 - CloudLinux7 custom values

=cut

use cPstrict;

use Log::Log4perl qw(:easy);

use parent 'Elevate::OS::RHEL';

use constant available_upgrade_paths => (
    'cloud',
    'cloudlinux',
);

use constant default_upgrade_to          => 'CloudLinux';
use constant ea_alias                    => 'CloudLinux_8';
use constant elevate_rpm_url             => 'https://repo.cloudlinux.com/elevate/elevate-release-latest-el7.noarch.rpm';
use constant is_experimental             => 1;
use constant leapp_can_handle_epel       => 1;
use constant leapp_can_handle_imunify    => 1;
use constant leapp_can_handle_kernelcare => 1;
use constant leapp_can_handle_python36   => 1;
use constant leapp_data_pkg              => 'leapp-data-cloudlinux';
use constant leapp_flag                  => '--nowarn';
use constant name                        => 'CloudLinux7';
use constant pretty_name                 => 'CloudLinux 7';

sub vetted_yum_repo ($self) {
    my @vetted_cloudlinux_yum_repo = (
        qr/^cloudlinux(?:-(?:base|updates|extras|compat|imunify360|elevate))?$/,
        qr/^cloudlinux-rollout(?:-[0-9]+)?$/,
        qr/^cloudlinux-ea4(?:-[0-9]+)?$/,
        qr/^cloudlinux-ea4-rollout(?:-[0-9]+)?$/,
        'cl-ea4',
        qr/^cl-mysql(?:-meta)?/,
    );

    my @repos = $self->SUPER::vetted_yum_repo();
    push @repos, @vetted_cloudlinux_yum_repo;
    return @repos;
}

1;
