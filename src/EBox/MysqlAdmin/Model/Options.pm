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

package EBox::MysqlAdmin::Model::Options;
use base 'EBox::Model::DataForm';

use strict;
use warnings;

use EBox::Global;
use EBox::Gettext;
use EBox::Types::Text;
use EBox::Types::Select;
use EBox::Exceptions::External;

sub _table
{
    my @tableDesc = (
         new EBox::Types::Select(
             fieldName => 'vHost',
             printableName => __('Virtual host'),
             editable => 1,
             populate => \&_virtualHosts,
             disableCache => 1,
             defaultValue => 'disabled',
             help => __('Virtual host where the MySql manager will be installed. This will disable the default /phpmyadmin url.')
         ),
    );

    my $dataForm = {
        tableName          => __PACKAGE__->nameFromClass(),
        printableTableName => __('General configuration'),
        pageTitle          => __('MysqlAdmin'),
        modelDomain        => 'MysqlAdmin',
        defaultActions     => [ 'editField', 'changeView' ],
        tableDescription   => \@tableDesc,
    };

    return $dataForm;
}

sub _virtualHosts
{
    my $webserver = EBox::Global->getInstance()->modInstance('webserver');
    my @options = ({ value => 'disabled' , printableValue => __('Disabled') });
    foreach my $vhost (@{$webserver->virtualHosts()}) {
        if ($vhost->{'enabled'}) {
            push (@options, { value => $vhost->{'name'} , printableValue => $vhost->{'name'} });
        }
    }
    return \@options;
}

# Method: notifyForeignModelAction
#
#      Called whenever an action is performed on VHostTable model
#      to check if our configured virtual host is going to disappear.
#
# Overrides:
#
#      <EBox::Model::DataTable::notifyForeignModelAction>
#
sub notifyForeignModelAction
{
    my ($self, $modelName, $action, $row) = @_;

    if ($modelName ne '/webserver/VHostTable') {
        return;
    }

    if ($action eq 'del') {
        my $vhost = $row->valueByName('name');
        my $myRow = $self->row();
        my $selected = $myRow->valueByName('vHost');
        if ($vhost eq $selected) {
            $myRow->elementByName('vHost')->setValue('disabled');
            $myRow->store();
            return __('The deleted virtual host was selected for ' .
                      'PhpMysqlAdmin. Maybe you want to select another one now.');
        }
    }

    return '';
}

sub productName
{
    my ($self) = @_;

    return $self->row()->valueByName('productName');
}

1;
