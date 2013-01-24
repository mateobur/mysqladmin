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


package EBox::MysqlAdmin::Model::OperationMode;
use base 'EBox::Model::DataForm';

use strict;
use warnings;

use EBox::Global;
use EBox::Gettext;
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
    my @tableDesc =
        (
         new EBox::Types::Select(
                               fieldName => 'mode',
                               printableName => __('Mode'),
                               editable => 1,
                               disableCache => 1,
                               populate => \&_populateMode,
                              ),
        );

      my $dataForm = {
                      tableName          => __PACKAGE__->nameFromClass(),
                      printableTableName => __('Operation mode'),
                      headTitle          => undef,
                      modelDomain        => 'MysqlAdmin',
                      defaultActions     => [ 'editField', 'changeView' ],
                      tableDescription   => \@tableDesc,

                     };



    return $dataForm;
}


sub headTitle
{
        return undef;
}

1;

