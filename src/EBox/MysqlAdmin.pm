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

# Class: EBox::MysqlAdmin
#
#      Class description
#

package EBox::MysqlAdmin;

use strict;
use warnings;

use base qw(EBox::Module::Service);

use EBox::Gettext;
use EBox::Service;
use EBox::Sudo;
use EBox::Config;
use EBox::WebServer;
use File::Slurp;

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
#        <EBox::MysqlAdmin> - the recently created module
#
sub _create
{
    my $class = shift;
    my $self = $class->SUPER::_create(name => 'mysqladmin',
                                      printableName => __('Mysql Manager'),
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
    my $options = $self->model('Options');

    $self->_setWebServerConf();
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

    my $folder = new EBox::Menu::Folder('name' => 'PhpMyAdmin',
                                        'text' => $self->printableName(),
                                        'separator' => 'Infrastructure',
                                        'order' => 455);

   $folder->add(
               new EBox::Menu::Item(
                   'url' => 'MysqlAdmin/View/Options',
                   'text' => 'Webserver',
              )
    );

    $folder->add(
               new EBox::Menu::Item(
                   'url' => 'MysqlAdmin/View/Hosts',
                   'text' => 'MySQL Hosts',
              )
    );

    $folder->add(
              new EBox::Menu::Item(
                  'url' => 'MysqlAdmin/View/Admin',
                  'text' => 'MySQL Local Admins',
              )
    );

    $root->add($folder);
}

sub _setWebServerConf
{
    my ($self) = @_;

    my @cmd;

    my $vHostPattern = EBox::WebServer::SITES_AVAILABLE_DIR . 'user-' .
                       EBox::WebServer::VHOST_PREFIX. '*/ebox-mysqladmin';
    push(@cmd, 'rm -f ' . "$vHostPattern");

    my $globalPattern = EBox::WebServer->GLOBAL_CONF_DIR . 'ebox-mysqladmin';
    push(@cmd, 'rm -f ' . "$globalPattern");
    EBox::Sudo::root(@cmd);

    return unless $self->isEnabled();

    my $vhost = $self->model('Options')->vHostValue();

    if ($vhost eq 'disabled') {
        my $destFile = EBox::WebServer->GLOBAL_CONF_DIR . 'ebox-mysqladmin';
        $self->writeConfFile($destFile, 'mysqladmin/apache.mas', []);
    } else {
        my $destFile = EBox::WebServer::SITES_AVAILABLE_DIR . 'user-' .
                       EBox::WebServer::VHOST_PREFIX. $vhost .'/ebox-mysqladmin';
        $self->writeConfFile($destFile, 'mysqladmin/apache.mas', []);
    }

    my $hostModel = $self->model('Hosts');

    $self->writeConfFile('/etc/phpmyadmin/config.inc.php','mysqladmin/config.inc.php.mas', [ sqlhosts => $hostModel->getHosts() ]);
}

# Method: initialSetup
#
# Overrides:
#   EBox::Module::Base::initialSetup
#
sub initialSetup
{
    my ($self, $version) = @_;

    $self->SUPER::initialSetup($version);

    unless ($version) {
        # Create default rules only if installing the first time
        # Add localhost as default MySQL server
        $self->model('Hosts')->add(
            host => 'localhost',
            port => 3306,
        );
    }
}

1;
