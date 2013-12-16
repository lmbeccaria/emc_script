# Customer.pm
# # 
# # Description: Customer class
# # by Luis Beccaria


package Customer;
use strict;
use warnings;

our $version = "0.1";

sub new
{
   my $class = shift;
   my $self  = {};

   bless( $self, $class );
   return $self;
}

sub name 
{
   my ($self, $name ) = @_;
   $self->{name} = $name if defined $name;
   return $self->{name};
}

sub total_spent
{
    my ($self, $amount) = @_;
    $self->{total_spent} += $amount if defined $amount;
    return $self->{total_spent};
}

1;
