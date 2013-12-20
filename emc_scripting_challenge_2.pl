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

  my @customers_data =  &find_all_customer_data('input.txt') ;

  #foreach my $n (@customers_data) { message("$n->{name}: $n->{amount}"); }

  my @customers_totals = &total_spent_per_customer(@customers_data);
  
  message("\nThese are the totals per customer:") ;
  foreach my $n (@customers_totals) { message ("$n->{name}: $n->{amount}"); }
  
  my @customers_per_category = &total_spent_per_categoy(@customers_data);
  
  message("\nThese are the totals per customer per category:") ;
  foreach my $n (@customers_per_category) { 
    unless ( defined($n->{groceries}) ) { $n->{groceries} = 0 } 
    unless ( defined($n->{entertainment}) ) { $n->{entertainment} = 0 } 
    unless ( defined($n->{fuel}) ) { $n->{fuel} = 0 } 
    message("$n->{name}  $n->{groceries} $n->{entertainment}  $n->{fuel} \n"); 
  }
  

  #Print Reports
  &print_reports(\@customers_totals, \@customers_per_category );

}

sub message
{
  my $m = shift or return;
  print("$m\n");
}

sub error
{
  my $e = shift || 'unkown error';
  print("$0: $e\n");
  exit 0;
}

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
         #print "found index: $index \n" ;
         $customers_totals[$index]{amount} += $entry->{amount} ;   
         #print "This customer exists: $customers_totals[$index]{name}: $customers_totals[$index]{amount} : cust ID: [$customer] : Exists ID: [$index]\n";
      } 
      else {
        $customers_totals[$customer]{name} = $entry->{name} ;   
        $customers_totals[$customer]{amount} = $entry->{amount} ; 

        #print "This customere NOT exists: $customers_totals[$customer]{name}: $customers_totals[$customer]{amount}  : cust ID: [$customer] : Exists ID: [$index]\n";
        $customer ++ ;
      }
    }
    return @customers_totals;
}

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
         #message("*********************\nfound index: $index Name: $name Cat: $category Amount: $amount\n") ;
        
         #message("Before Name: $customers_totals[$index]{name} Categ: $customers_totals[$index]{$category} Amount: $customers_totals[$index]{amount}\n"); 

         # Check if category element already in the @customeres_totals.         
        if (( $name eq $customers_totals[$index]{name}) && ( defined($customers_totals[$index]{$category})) )
        {
           $customers_totals[$index]{$category} += $amount ; 

           #message("$customers_totals[$index]{name} : $customers_totals[$index]{$category} \n"); 
           # message("cust ID: [$customer] : Exists ID: [$index]\n");
        
        } else { # If category not in the hash key yet add it.

            # message("------------------------------\nCustomer name exists but NOT category:\n") ;

           $customers_totals[$index]{$category} = $amount ; 
         
           #message("Name: $customers_totals[$index]{name} Categ: $customers_totals[$index]{$category}\n"); 
           # message("cust ID: [$customer] : Exists ID: [$index]\n");
        } 
     } 
      else {
          #message("-------------------------------\nCustomer exisit NOT:\n");
        $customers_totals[$customer]{name} = $name ;   
        $customers_totals[$customer]{$category} = $amount ; 

        #message("Name: $customers_totals[$customer]{name} Categ: $customers_totals[$customer]{$category}\n");
        # message("cust ID: [$customer] : Exists ID: [$index]\n");
        
         $customer ++ ;
      }
      $amount =0;
      message("$customers_totals[$customer]{name} $customers_totals[$customer]{$category}\n");
    }
    return @customers_totals;
}


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

  $line = "Name  Groceries  Entertaiment  Fuel\n";  
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

sub format_line
{
  my ($string) = @_;
  my ($customer, $category, $amount) = ($string =~ m/(.*?)\|(.*?)\|(.*?)$/); 

  my $fstring = $customer . ": " . $amount . "\n";
  return $fstring;
}
