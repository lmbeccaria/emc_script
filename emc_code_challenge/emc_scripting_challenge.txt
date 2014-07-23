#!/usr/bin/perl
# # Description: Credit card log parser
# #   EMC code challenge.  
# # by Luis Beccaria -- luis.m.beccaria@gmail.com
# # 

use strict;
use warnings;
use IO::File;

my $number_arguments = $#ARGV +1;

if ( $number_arguments != 1) {
   print "\nERROR: Wrong number of arguments.\n"; 
   print "Usage:\t$0 <file name>\neg:\t$0 input.txt\n\n";
   print "File's format should be:\t'Customer|Category|Amount'\n\n";
   exit;
}
my $datafile = $ARGV[0];

main(@ARGV);


sub main 
{
  # List of categories. More categories can be added to this list  
  my @categories = qw/groceries entertainment fuel/; 

  # Loads data from file
  my @data =  &find_all_customer_data($datafile) ;

  # Find all customers
  my @customers_names = &find_customers_names(@data);

  # Generates an array with the Totals for each customer
  my @customers_totals = &total_spent_per_customer(\@data);
  
  # Generates an array with he totals PER CATEGORY per customer
  my @customers_per_category = &total_spent_per_categoy(\@data,\@categories, \@customers_names);

  # Generates an array with the highest spender per category
  my @highest_spenders = &sort_highest_spenders(\@customers_per_category, \@categories) ;

  #Print Reports
  &print_reports(\@customers_totals, \@customers_per_category, \@highest_spenders );

}

#####################################################################3
# This function finds all customers names
#####################################################################3
sub find_customers_names 
{
  my (@data) = @_;
  my @customers_names;
  my $index = 0;
  
  foreach my $entry (@data) {
      #my $exists = $_ = grep { $customers_names[$index] =~ /^$entry->{name}$/ } 0..$#customers_names;
    
    # Checks if  the customer name exists already. Then dont push them
    unless ( $entry->{name} ~~ @customers_names ) {
      $customers_names[$index] = $entry->{name}; 
      $index++;
    }  
  }
  return @customers_names;
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
    chomp($line);  
    my ($name, $category, $amount) = ($line =~ m/^(.*)?\|(.*)?\|\$(.*)?$/);
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
    my ($data) = @_;
    my @customers_totals ;
    my $customer = 0;
    my $index = 0;
    my $exists =0;

    foreach my $entry (@$data)
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
    my ($data, $categories, $customers_names) = @_;
    my @customers_totals ;
    my $customer = 0;
    my $index = 0;
    my $name_exists =0;
    my $category;
    
    # Initialize @customers_totlas array
    for( my $n=0; $n < scalar(@$customers_names); $n++) {
      $customers_totals[$n]{name} = @$customers_names[$n] ;
      #  print "$customers_totals[$n]{name}:";
      foreach my $c (@$categories) {
        $customers_totals[$n]{$c} = 0; 
        # print "$customers_totals[$n]{$c}:";
      } 
      print "\n";
    }


    foreach my $entry (@$data)
    {
      my $name = $entry->{name};
      my $category = $entry->{category} ; 
      my $amount;

      if ( defined($entry->{amount}) )
      {
        $amount = $entry->{amount} ; 
      } else {
        $amount = 0 ; 
      }

      my $name_exists = $_ = grep { $customers_totals[$_]{name} =~ /^$name$/ } 0..$#customers_totals;

      if ( $name_exists )
      {

        # Find the index in @customers_totals  where the customer's name matches
        for(my $i=0; $i < scalar(@customers_totals); $i++ )
        {
          if ($name eq $customers_totals[$i]{name}) { $index = $i; last;}
        }

        $customers_totals[$index]{$category} += $amount ; 
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
  my ($data,$categories) = @_;
  my $index =0;
  my @highest ;

  # Initialize @highest array 
  for(my $cat=0; $cat < scalar(@$categories); $cat++) {
    
    $highest[$cat]{cat_name} = @$categories[$cat];  
    $highest[$cat]{cat_amount} = 0;  
    $highest[$cat]{customer} = "   ";  
    #print "cat: $highest[$cat]{cat_name}:$highest[$cat]{cat_amount}:$highest[$cat]{customer}:--[index]: $cat\n";   
  } 

  foreach my $entry (@$data) {

    foreach my $cat (@$categories) {
      
      # Find the index where the category's name matches
      for(my $i=0; $i < scalar(@highest); $i++ )
      {
        if ($cat eq $highest[$i]{cat_name}) { $index = $i; last;}
      }
        
      if ( $entry->{$cat} > $highest[$index]{cat_amount} ){

        $highest[$index]{cat_amount} = $entry->{$cat} ;
        $highest[$index]{customer} = $entry->{name};
      }

    }  
  } 
  
  return @highest ;
}


#####################################################################3
# Prints reports. Output file: output.txt
#####################################################################3
sub print_reports
{
  my ( $customers_totals, $customers_per_category, $highest_spenders ) = @_; 
  my $file = "output.txt";
  my $line;  
  my $fh = IO::File->new($file, 'w') or die("cannot open $file ($!)");

  $line = "\n----------------------------------------\nReport 1: Totals Spent per customers\n----------------------------------------\n";
  $fh->print($line);

  foreach my $entry (@$customers_totals)
  {
    $line = $entry->{name} . ":\t\t" .  '$'. $entry->{amount} . "\n";
    $fh->print($line);
  }

  $line = "\n----------------------------------------------------------------\nReport 2: Totals Spent per customers per category\n----------------------------------------------------------------\n";
  $fh->print($line);

  $line = "Name\t\tGroceries\tEntert.\t\tFuel\n";  
  $fh->print($line);
  $line = "-----------------------------------------------------------------\n";
  $fh->print($line);

  foreach my $entry (@$customers_per_category)
  {
      unless ( defined($entry->{groceries}) ) { $entry->{groceries} = 0 } 
      unless ( defined($entry->{entertainment}) ) { $entry->{entertainment} = 0 } 
      unless ( defined($entry->{fuel}) ) { $entry->{fuel} = 0 } 

    $line = $entry->{name} . "\t\t" . '$' . $entry->{groceries} . "\t\t" . ' $' . $entry->{entertainment} . "\t\t" . '$' . $entry->{fuel} . "\n";
    $fh->print($line);
  }    

  $line = "\n----------------------------------------------------------------\nReport 3: Highest spender in each category\n----------------------------------------------------------------\n";
  $fh->print($line);

  $line = "Category\t\tHighest Spender\t\tAmount\n----------------------------------------------------------------\n";
  $fh->print($line);

  foreach my $entry (@$highest_spenders)  
  {
     my @k = keys $entry; 
     my @v = values $entry;
     for (my $i=0; $i < scalar(@k); $i++) { 
       $line = " $v[$i]\t\t"; 
       $fh->print($line);
     } 
     $line = "\n";
     $fh->print($line);
  } 
  #print `cat output.txt`;
  print "\nThe reports were successfully generated!! -- FILE NAME: $file\n\n" 
}


#####################################################################3
#  Auxiliary functions for debugging
#####################################################################3
sub print_array {
  my (@arr) = @_;
  foreach my $i (@arr) {
    print "$i ";
  }
  print "\n";
}

sub print_array_of_hashes {
  my ( @arr) = @_; 
  foreach my $c (@arr) { 
     my @k = keys $c; 
     my @v = values $c;
     for (my $i=0; $i < scalar(@k); $i++) { 
       print " $k[$i]: $v[$i] "; 
     } 
     print "\n";
  }
}
