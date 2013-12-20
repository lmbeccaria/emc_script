#!/usr/bin/perl
# # Description:
# # by Luis Beccaria -- luis.m.beccaria@gmail.com
# # 

use strict;
use warnings;
use IO::File;

main(@ARGV);

# customer|category|amount

sub main 
{
  # Loads the data from file
  my @customers_data =  &find_all_customer_data('input.txt') ;

  # Generates an array with the Totals for each customer
  my @customers_totals = &total_spent_per_customer(@customers_data);
  
  # Generates an array with he totals PER CATEGORY per customer
  my @customers_per_category = &total_spent_per_categoy(@customers_data);

  # Generates an array with the highest spender per category
  my @highest_spenders = &sort_highest_spenders(@customers_per_category) ;

  #Print Reports
  &print_reports(\@customers_totals, \@customers_per_category );

}

#####################################################################3
# This function collects all data  customer from file
#####################################################################3

sub find_all_customer_data
{
  my ($filename) = @_;
  my $filehandle = IO::File->new($filename, 'r') or die("cannot open $filename ($!)");

  my $index = 0;
  my @customers;  

  while(my $line = $filehandle->getline)
  {
    my ($name, $category, $str_amount) = ($line =~ m/(.*)?\|(.*)?\|(.*)?$/);
    chomp($name);
    chomp($category);
    chomp($str_amount);
    my ($amount) = ($str_amount =~ m/\$(.*)?$/) ;

    $customers[$index]{name} = $name ;
    $customers[$index]{category} = $category ;
    $customers[$index]{amount} = $amount ;

    $index++;
  }
 return @customers;
} 

#####################################################################3
# Function returns the total amounts spent per customer
#####################################################################3
sub total_spent_per_customer
{
    my (@data) = @_;
    my @customers_totals ;
    my $customer = 0;
    my $index = 0;
    my $exists =0;

    foreach my $entry (@data)
    {
      $exists = $_ = grep { $customers_totals[$_]{name} =~ /^$entry->{name}$/ } 0..$#customers_totals;
        
      if ($exists)
      {
         # Find the index in @customers_totals  where the customer name matches
         for(my $i=0; $i < scalar(@customers_totals); $i++ )
         {
            if ($entry->{name} eq $customers_totals[$i]{name}) { $index = $i; last;}
         }
         $customers_totals[$index]{amount} += $entry->{amount} ;   
      } 
      else {
        $customers_totals[$customer]{name} = $entry->{name} ;   
        $customers_totals[$customer]{amount} = $entry->{amount} ; 

        $customer ++ ;
      }
    }
    return @customers_totals;
}

#####################################################################3
# Function returns the total amounts spent per customer per category
#####################################################################3
sub total_spent_per_categoy
{
    my (@data) = @_;
    my @customers_totals ;
    my $customer = 0;
    my $index = 0;
    my $name_exists =0;
    my $category;
    
    foreach my $entry (@data)
    {
      my $name = $entry->{name};
      my $category = $entry->{category} ; 
      my $amount = $entry->{amount} ; 

      $name_exists = $_ = grep { $customers_totals[$_]{name} =~ /^$name$/ } 0..$#customers_totals;
      if ($name_exists)
      {
         # Find the index in @customers_totals  where the customer's name matches
         for(my $i=0; $i < scalar(@customers_totals); $i++ )
         {
            if ($name eq $customers_totals[$i]{name}) { $index = $i; last;}
         }

         # Check if category element already in the @customeres_totals.         
        if (( $name eq $customers_totals[$index]{name}) && ( defined($customers_totals[$index]{$category})) )
        {
            # If a category already existes for a customer, add the amount to the exisitng amount.
           $customers_totals[$index]{$category} += $amount ; 

        } else { 
           # If one of the category is not in the hash key yet, add it.
           unless ( defined($customers_totals[$index]{$category}) )
           {
              $customers_totals[$index]{$category} = 0 ; 
           }
           $customers_totals[$index]{$category} = $amount ; 
        } 
     } 
      else {
          # If customer has not been added yet to customers_totals array, add it's name and category amount  
        $customers_totals[$customer]{name} = $name ;   
        $customers_totals[$customer]{$category} = $amount ; 

        $customer ++ ;
      }
      $amount =0;
    }
    # Remove empty/blank values from array
    @customers_totals = grep { $_ && !m/^\s+$/ } @customers_totals ; 
    
    return @customers_totals;
}


#####################################################################3
# Function to sort the Highest spender per category
#####################################################################3
sub sort_highest_spenders
{
  my (@data) = @_;
  
  my $groceries =0 ;
  my $entertaiment =0;
  my $fuel=0;
  my @highest = {'groceries', 0, 'entertaiment', 0,'fuel', 0 } ;

  foreach my $entry (@data)
  {
   unless( defined($entry->{groceries}) )  { $entry->{groceries} = 0 } 
   unless( defined($entry->{entertaiment}) )  { $entry->{entertaiment} = 0 } 
   unless( defined($entry->{fuel}) )  { $entry->{fuel} = 0 } 

   if $entry->{groceries} > $highest{'groceries'} 
   {
     $highest{'category'} = 'groceries' ;
     $highest{'amount'} = $entry->{groceries} ;
    $highest{'name'} = $entry->{name};
   }

   if $entry->{entertaiment} > $highest{'entertaiment'}
   {
     $highest{'category'} = 'entertaiment' ;
     $highest{'amount'} = $entry->{entertaiment} 
     $highest{'name'} = $entry->{name};
   }

   if $entry->{fuel} > $highest{'fuel'}
   {
     $highest{'category'} = 'fuel' ;
     $highest{'amount'} = $entry->{fuel} 
     $highest{'name'} = $entry->{name};
   }

   print "$highest{'category'}: $highest{'groceries'} | entert: $highest{'entertaiment'} | fuel: $highest{'fuel'} \n";
  } 
}


#####################################################################3
# Prints reports. Output file: output.txt
#####################################################################3
sub print_reports
{
  my ( $customers_totals,$customers_per_category ) = @_; 
  my $file = "output.txt";
  my $line;  
  my $fh = IO::File->new($file, 'w') or die("cannot open $file ($!)");

  $line = "\n----------------------------------------\nReport 1: Totals Spent per customers\n----------------------------------------\n";
  $fh->print($line);

  foreach my $entry (@$customers_totals)
  {
    $line = $entry->{name} . ': $'. $entry->{amount} . "\n";
    $fh->print($line);
  }

  $line = "\n----------------------------------------\nReport 2: Totals Spent per customers per category\n----------------------------------------\n";
  $fh->print($line);

  $line = "Name   Groceries  Entert.  Fuel\n";  
  $fh->print($line);
  $line = "----------------------------------------\n";
  $fh->print($line);

  foreach my $entry (@$customers_per_category)
  {
      unless ( defined($entry->{groceries}) ) { $entry->{groceries} = 0 } 
      unless ( defined($entry->{entertainment}) ) { $entry->{entertainment} = 0 } 
      unless ( defined($entry->{fuel}) ) { $entry->{fuel} = 0 } 

    $line = $entry->{name} . "\t" . '$' . $entry->{groceries} . "\t" . ' $' . $entry->{entertainment} . "\t" . '$' . $entry->{fuel} . "\n";
    $fh->print($line);
  }    

  $line = "\n----------------------------------------\nReport 3: Highest spender in each category\n----------------------------------------\n";
  $fh->print($line);

  print "\nThe reports were successfully generater -- File name: $file\n\n" 
}

