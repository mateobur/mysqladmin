# Copyright (C) 2009-2012 eBox Technologies S.L.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# Class: EBox::MyAdmin
#
#      Class description
#

package EBox::MyAdmin;

use strict;
use warnings;

use base qw(EBox::Module::Service);

use EBox::Gettext;
use EBox::Service;
use EBox::Sudo;
use EBox::Config;
use EBox::WebServer;
use File::Slurp;

use constant {
    MAIN_INC_FILE => '/etc/roundcube/main.inc.php',
    DES_KEY_FILE  => EBox::Config::conf() . 'roundcube.key',
    SIEVE_PLUGIN_INC_USR_FILE =>
           '/usr/share/roundcube/plugins/managesieve/config.inc.php',
    SIEVE_PLUGIN_INC_ETC_FILE =>
           '/etc/roundcube/managesieve-config.inc.php',
    ROUNDCUBE_DIR => '/var/lib/roundcube',
    HTTPD_WEBMAIL_DIR => '/var/www/webmail',
};


# Group: Protected methods

# Constructor: _create
#
#        Create an module
#
# Overrides:
#
#        <EBox::Module::Service::_create>
#
# Returns:
#
#        <EBox::MyAdmin> - the recently created module
#
sub _create
{
    my $class = shift;
    my $self = $class->SUPER::_create(name => 'MyAdmin',
                                      printableName => __('MySQL Manager'),
                                      @_);
    bless($self, $class);
    return $self;
}

# Method: _setConf
#
#        Regenerate the configuration
#
# Overrides:
#
#       <EBox::Module::Service::_setConf>
#
sub _setConf
{
    my ($self) = @_;

    my $params;

    my $options = $self->model('Options');
}

# Group: Public methods

# Method: menu
#
#       Add an entry to the menu with this module
#
# Overrides:
#
#       <EBox::Module::menu>
#
sub menu
{
    my ($self, $root) = @_;

    $root->add(
               new EBox::Menu::Item(
                   'url' => 'MyAdmin/View/Options',
                   'text' => $self->printableName(),
                   'separator' => 'Infrastructure',
                   'order' => 455,
              )
    );
}

# Method: usedFiles
#
#        Indicate which files are required to overwrite to configure
#        the module to work. Check overriden method for details
#
# Overrides:
#
#        <EBox::Module::Service::usedFiles>
#

# Method: disableActions
#
#        Rollback those actions performed by <enableActions> to
#        disable the module
#
# Overrides:
#
#        <EBox::Module::Service::disableActions>
#
sub disableActions
{

}

#  Method: enableModDepends
#
#   Override EBox::Module::Service::enableModDepends
#
sub enableModDepends
{
    return ['webserver'];
}

sub _setWebServerConf
{
    my ($self) = @_;

    # Delete all possible zentyal-webmail configuration
    my @cmd = ();
    push(@cmd, 'rm -f ' . HTTPD_WEBMAIL_DIR);
    my $vHostPattern = EBox::WebServer::SITES_AVAILABLE_DIR . 'user-' .
                       EBox::WebServer::VHOST_PREFIX. '*/ebox-webmail';
    push(@cmd, 'rm -f ' . "$vHostPattern");
    my $globalPattern = EBox::WebServer::GLOBAL_CONF_DIR . 'ebox-webmail';
    push(@cmd, 'rm -f ' . "$globalPattern");
    EBox::Sudo::root(@cmd);

    return unless $self->isEnabled();

    my $vhost = $self->model('Options')->vHostValue();

    if ($vhost eq 'disabled') {
        my $destFile = EBox::WebServer::GLOBAL_CONF_DIR . 'ebox-webmail';
        $self->writeConfFile($destFile, 'webmail/apache.mas', []);
    } else {
        my $destFile = EBox::WebServer::SITES_AVAILABLE_DIR . 'user-' .
                       EBox::WebServer::VHOST_PREFIX. $vhost .'/ebox-webmail';
        $self->writeConfFile($destFile, 'webmail/apache.mas', []);
    }
}

1;
