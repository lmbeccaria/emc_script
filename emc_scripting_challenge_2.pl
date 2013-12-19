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
     message("Name: $n->{name} ---- Groceries: $n->{groceries} Entretaiment: $n->{entertainment} Fuel: $n->{fuel}"); 
  }
  
  #Print Reports
#  &print_report('input.txt', 'output.txt');

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
    my ($name, $category, $str_amount) = ($line =~ m/(.*?)\|(.*?)\|(.*?)$/);
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
        if (( $name eq $customers_totals[$index]{name}) && ( defined $customers_totals[$index]{$category}) )
        {
            #  message("---------------------------\nCustomer name and category exisits:\n");
           $customers_totals[$index]{$category} += $amount ; 

           # message("Name: $customers_totals[$index]{name} Categ: $customers_totals[$index]{$category} \n"); 
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
    }
    return @customers_totals;
}


sub print_report
{
  my ($line, $newline);  
  my ( $origfile, $newfile ) = @_; 
  my $origfh = IO::File->new($origfile, 'r') or die("cannot open $origfile ($!)");
  my $newfh = IO::File->new($newfile, 'w') or die("cannot open $newfile ($!)");
  
  while($line = $origfh->getline) 
  {
    $newline = &format_line($line);
    
    print $newline;

    # Copy to new file
    $newfh->print($newline);
  }

  print "The reports were successfully generater -- File name: $newfile\n\n" 
}

sub format_line
{
  my ($string) = @_;
  my ($customer, $category, $amount) = ($string =~ m/(.*?)\|(.*?)\|(.*?)$/); 

  my $fstring = $customer . ": " . $amount . "\n";
  return $fstring;
}
