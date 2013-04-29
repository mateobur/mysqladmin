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


package EBox::MysqlAdmin::Model::Admin;
use base 'EBox::Model::DataTable';

use strict;
use warnings;

use EBox::Global;
use EBox::Gettext;
use EBox::Types::Text;
use EBox::Types::Password;
use EBox::Types::Host;
use EBox::Types::Select;
use EBox::Exceptions::External;
use EBox::MysqlAdmin::RootDBEngine;

sub new
{
    my $class = shift @_ ;

    my $self = $class->SUPER::new(@_);
    bless($self, $class);

    return $self;
}

sub addedRowNotify
{
	my ($self, $row) = @_;
        my $adminname = $row->valueByName('username');
        my $password = $row->valueByName('password');

        my $dbengine = new EBox::MysqlAdmin::RootDBEngine();
	$dbengine->do('CREATE USER \'' . $adminname . '\'@\'localhost\' IDENTIFIED BY \''. $password . '\';'); 
	$dbengine->do('GRANT ALL PRIVILEGES ON *.* TO \'' . $adminname . '\'@\'localhost\' WITH GRANT OPTION;');
}

sub _table
{
   my @tableHeader =
   (
     new EBox::Types::Text(
           'fieldName'     => 'username',
           'printableName' => __('Username'),
           'editable'      => 1,
       ),

     new EBox::Types::Password(
           'fieldName'     => 'password',
           'printableName' => __('Password'),
           'editable'      => 1,
       ),
     );

    my $dataTable =
    {
        tableName          => 'Admin',
        printableTableName => __('MySQL Local Admins'),
        printableRowName   => __('Admins'),
        defaultActions     => ['add', 'del', 'editField', 'changeView' ],
        tableDescription   => \@tableHeader,
        class              => 'dataTable',
        modelDomain        => 'MysqlAdmin',
    };

    return $dataTable;

}

1;
