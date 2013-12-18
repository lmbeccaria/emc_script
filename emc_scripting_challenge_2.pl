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

  #foreach my $n (@customers_data) { print "$n->{name}: $n->{amount}\n"; }

  my @customers_totals = &total_spent_per_customer(@customers_data);
  foreach my $n (@customers_totals) { print "$n->{name}: $n->{amount}\n"; }
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
    #chomp($str_amount);
    my $amount;
    if ( $str_amount =~ s/\$(\d+).*/$1/g) { $amount = int($1) }

    
    #my ($exists) = grep { $customers[$_] =~ /^$name$/ } 0..$#customers; 

    #my ($exists) = $_ = grep( /^$name$/, $customers[$index]{name} );

    #($exisits) = $_ = ($customers[$index]{'name'} eq $name)

    $customers[$index]{name} = $name ;
    $customers[$index]{category} = $category ;
    $customers[$index]{amount} = $amount ;

    $index++;
  }
 return @customers;
} 

sub total_spent_per_customer
{
    my (@customers_data) = @_;
    my @customers_totals ;

    my $name = $customers_data

#    #print "name: $name -- amount: $amount||||\n";
#
#    if ($customers[$index]{name} eq $name)
#    
#    #if ( $exists )
#    #if ( (defined $customers[$index]{name}) && ($name ~~ $customers[$index]{name}) )
#    { 
#        #print "Index: $index -- $customers[$index]{name} \n";
#          #my ($exists) = grep { $customers[%_] =~ /^$name$/ } 0..$#customers;   
#          print "customer exists\n";
#        $customers[$index]->{amount} += $amount;
#  
#     } else {
#        $customers[$index]->{name} = $name;
#        $customers[$index]->{amount} = $amount;
#
#        #    print "$name : $customers[$index]->{name} : $customers[$index]->{amount} \n"
#     }
#    
#    #if ($customers[$index]->{name} eq $name))
#     #{
#         #push(@customers, $name);
#         # %customers{$name} = $amount;
#     #}
#     #print $name . "\n";
#     $index++;
#  
#  #foreach my $n (@customers) { print "$n->{name}: $n->{amount}\n"; }
#
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
