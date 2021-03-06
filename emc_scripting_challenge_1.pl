#!/usr/bin/perl
# # Description:
# # by Luis Beccaria -- luis.m.beccaria@gmail.com
# # 

use strict;
use warnings;
use IO::File;

use Customer;

main(@ARGV);

# customer|category|amount

sub main 
{
    #my $customer = Customer->new;
    #$customer->name("Julius");

    #message($customer->name . ":");

   &find_customers('input.txt')

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

sub find_customers
{
  my ($filename) = @_;
  my $filehandle = IO::File->new($filename, 'r') or die("cannot open $filename ($!)");

  my @customers;
  while(my $line = $filehandle->getline)
  {
     my ($name) = ($line =~ m/(.*?)\|/);
    
     unless ( grep( /^$name$/, @customers ) ) 
     {
        push(@customers, $name);
     }
     #print $name . "\n";
  }
  foreach my $n (@customers) { print "$n\n"; }

  return @customers;
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
