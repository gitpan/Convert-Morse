# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

use Test;
use strict;
use vars qw/$loaded/;

BEGIN 
  {
  $| = 1;
  unshift @INC,'../lib';
  chdir 't' if -d 't';
  plan tests => 34;
  }
END 
  {
  print "not ok 1\n" unless $loaded;
  }

use Convert::Morse;
$loaded = 1;
ok (1,1);

######################### End of black magic.

# test wether some partial inputs are morsable/morse

my (@parts,$try,$rc);

$try = "Convert::Morse::is_morsable('Helo World.');";
$rc = eval $try;
print " # '$try' expected 'undef' but got '$rc'\n" 
   if !ok ($rc,1);

$try = "Convert::Morse::is_morse('- . ----- .-.-.-');";
$rc = eval $try;
print " # '$try' expected 'undef' but got '$rc'\n" 
   if !ok ($rc,1);

$try = 'Convert::Morse::is_morsable(\'!@$%=\');';
$rc = eval $try;
print " # '$try' expected '1' but got '$rc'\n" 
   if !ok ($rc,undef);

$try = "Convert::Morse::is_morse('- . 3');";
$rc = eval $try;
print " # '$try' expected '1' but got '$rc'\n" 
   if !ok ($rc,undef);


while (<DATA>)
  {
  chomp;
  @parts = split /:/;
  $parts[0] = '' if !defined $parts[0];
  $parts[1] = '' if !defined $parts[1];
  # test wether convert between 0 and 1 works
  $try = "Convert::Morse::as_ascii('$parts[0]');";
  
  $rc = eval "$try";
  print " # '$try' expected '$parts[1]' but got '$rc'\n" 
   if !ok ($rc,"$parts[1]");
 
  next if $parts[0] =~ /[^-.\s]/; # no reverse

  $try = "Convert::Morse::as_morse('$parts[1]');";
  
  $rc = eval "$try";
  print " # '$try' expected '$parts[0]' but got '$rc'\n" 
   if !ok ($rc,"$parts[0]");

  }

1;

__END__
.:E
-:T
-----:0
.----:1
..---:2
...--:3
....-:4
.....:5
-....:6
--...:7
---..:8
----.:9
:
----- ----- ----- -----:0000
By - . .-.. ... .-.-.-  in:By TELS. in
