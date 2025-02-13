package Elevate::Components::RpmDB;

=encoding utf-8

=head1 NAME

Elevate::Components::RpmDB

Perform some maintenance on the RPM database.

=cut

use cPstrict;

use Elevate::Constants ();
use Elevate::DNF       ();

use Cwd           ();
use File::Copy    ();
use Log::Log4perl qw(:easy);

use Cpanel::Pkgr      ();
use Cpanel::Yum::Vars ();

use parent qw{Elevate::Components::Base};

sub pre_leapp ($self) {

    $self->run_once("_cleanup_rpms");

    return;
}

sub _cleanup_rpms ($self) {

    # potential to remove other things, but the goal here to remove cpanel packages provided by rpm.versions
    $self->rpm->remove_cpanel_arch_rpms();

    return;
}

sub post_leapp ($self) {

    $self->run_once("_sysup");

    return;
}

sub _sysup ($self) {
    Cpanel::Yum::Vars::install();
    $self->dnf->clean_all();

    my $epel_url = 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm';

    # no failures once already installed: no need to check for the epel-release version
    unless ( Cpanel::Pkgr::is_installed('epel-release') ) {
        $self->dnf->install_rpm_via_url($epel_url);
    }

    $self->dnf->config_manager_enable('powertools');
    $self->dnf->config_manager_enable('epel');

    # Break cpanel-perl (NOTE: This only works on perl 5.36)
    $self->ssystem(qw{/usr/bin/rm -f /usr/local/cpanel/3rdparty/perl/536/cpanel-lib/X/Tiny.pm});
    {
        local $ENV{'CPANEL_BASE_INSTALL'} = 1;    # Don't fix more than perl itself.
        $self->ssystem(qw{/usr/local/cpanel/scripts/fix-cpanel-perl});
    }
    $self->dnf->update_allow_erasing( '--disablerepo', 'cpanel-plugins' );
    $self->ssystem_and_die(qw{/usr/local/cpanel/scripts/sysup});

    return;
}

1;
