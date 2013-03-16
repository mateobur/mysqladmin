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


package EBox::MysqlAdmin::Model::Hosts;
use base 'EBox::Model::DataTable';

use strict;
use warnings;

use EBox::Global;
use EBox::Gettext;
use EBox::Types::Text;
use EBox::Types::Host;
use EBox::Types::Select;
use EBox::Exceptions::External;

sub new
{
    my $class = shift @_ ;

    my $self = $class->SUPER::new(@_);
    bless($self, $class);

    return $self;
}

sub _table
{
   my @tableHeader =
   ( 
     new EBox::Types::Host(
           'fieldName'     => 'host',
           'printableName' => __('Hostname'),
           'editable'      => 1,
       ),

     new EBox::Types::Port(
           'fieldName'     => 'port',
           'printableName' => __('MySQL port'),
           'editable'      => 1,
           'defaultValue'  => 3360,
       ),
     );

    my $dataTable =
    {
        tableName          => 'Hosts',
        printableTableName => __('MySQL Hosts'),
        printableRowName   => __('Host'),
        defaultActions     => ['add', 'del', 'editField', 'changeView' ],
        tableDescription   => \@tableHeader,
        class              => 'dataTable',
        sortedBy           => 'host',
        modelDomain        => 'MysqlAdmin',
    };

    return $dataTable;
 
}

sub getHosts
{
    my ($self) = @_;

    my @hosts = ();

    foreach my $id (@{$self->enabledRows()}) {

        my $row = $self->row($id);
        my $host = $row->valueByName('host');
        my $port = $row->valueByName('port');
        push (@hosts, {host => $host, port => $port});

    }
    return \@hosts;
}


1;
