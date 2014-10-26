#!/usr/bin/perl -w

#############################################################################
# Convert/Morse.pm -- package to convert between ASCII and MORSE code.
#
# (C) ..--- ----- ----- ----- by - . .-.. ... .-.-.-  All rights reserved.
#############################################################################

# todo

# German umlaute etc (how to represent in ASCII?).
# see: http://member.nifty.ne.jp/je1trv/CW_J_e.htm

package Convert::Morse;
use vars qw($VERSION);
$VERSION = 0.03;	# Current version of this package
require  5.6.0;		# requires this Perl version or later

use Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw( as_morse as_ascii is_morse is_morsable
               );
#@EXPORT = qw( );
use strict;

#############################################################################
# global variables

my $morse_ascii;	# hash of morse symbols (morse => ascii)
my $ascii_morse;	# hash of ascii symbols (ascii => morse)
my $regexp_ascii_morse;	# compiled regexp
my $regexp_morse_ascii;	# compiled regexp
my $error;		# last error message

sub as_morse
  {
  # convert ASCII text into morse code
  my $ascii = shift; # no || "" because fail for '0'
  return "" if !defined $ascii || $ascii eq ""; 
  undef $error;
  $ascii = uc($ascii);	# 'Helo' => 'HELO'
  $ascii =~ s/\G$regexp_ascii_morse/_convert($1,$ascii_morse);/gec;
  $ascii =~ s/\s$//;  	# remove last space
  $ascii;
  }

sub as_ascii
  {
  # convert morse text into ascii code
  my $morse = shift;
  return "" if !defined $morse || $morse eq "";
  # because regexps expects a space (to avoid testing for \s|$)
  $morse .= ' ' if substr($morse,-1,1) ne ' '; 
  undef $error;
  $morse =~ s/\G$regexp_morse_ascii/_convert($1,$morse_ascii);/gec;
  $morse =~ s/\s+/ /g;	# collapse spaces 
  $morse =~ s/\s$//;  	# remove last space
  $morse;
  }

sub _convert
  {
  my $token = shift;
  return '' if !defined $token;
  my $hash = shift;
  $token =~ s/\s$// if length($token) > 1; # remove trailing space if not ' '
  my $sym = $hash->{$token};
  if (!defined $sym)
    {
    $error = "Undefined token '$token'"; return $token; 
    }
  #print "'",quotemeta($token),"' => '",quotemeta($sym),"'\n";
  return $sym;
  }

sub is_morsable
  {
  # returns true wether input can be completely expressed as morse
  my $text = shift || "";
  my $morse = as_morse($text);
  return error() ? undef : 1;
  }

sub is_morse
  {
  # returns true wether input is valid Morse code
  my $text = shift || "";
  my $ascii = as_ascii($text);
  return error() ? undef : 1;
  }

sub error
  {
  # return last parse error or undef for ok
  return $error;
  }

#############################################################################
# self initalization

sub tokens
  {
  # set/return hash of valid/invalid tokens (in form of ascii => morse)
  my $tokens = shift;
  if (defined $tokens)
    {
    $morse_ascii = {}; $ascii_morse = {};
    foreach (keys %$tokens)
      {
      $ascii_morse->{$_} = $tokens->{$_}.' ';
      $morse_ascii->{$tokens->{$_}} = $_;
      }
    # preserve spaces
    # compile a big regexp for token parsing
    $regexp_ascii_morse = '(' . 
      join('|', map { quotemeta } keys %$ascii_morse) 
      . '|.)';
    $regexp_morse_ascii = '(' .  
      join('\s|', map { quotemeta } keys %$morse_ascii) 
      . '\s|.)';
    # fix space handling
    foreach (" ","\t","\n")
      {
      $ascii_morse->{$_} = $_; 
      $morse_ascii->{$_} = $_;
      }
    #print "$regexp_ascii_morse\n";
    #print "$regexp_morse_ascii\n";
    #foreach (keys %$ascii_morse)
    #  {
    #  print "'$_' => '$ascii_morse->{$_}'\n";
    #  }
    }
  # return current token set
  my $copy = {}; 
  foreach (keys %$ascii_morse) { $copy->{$_} = $ascii_morse->{$_}; }
  return $copy;
  }

BEGIN
  {
  tokens( { 
	'.'	=>	'.-.-.-',
	','	=>	'--..--',
	':'	=>	'---...',
	'?'	=>	'..--..',
	"'"	=>	'.----.',
	'-'	=>	'-....-',
	';'	=>	'-.-.-',
	'/'	=>	'-..-.',
	'('	=>	'-.--.-',
	'"'	=>	'.-..-.',
	'_'	=>	'..--.-',
	qw( 
	A	.-
	B	-...
	C	-.-.
	D	-..
	E	.
	F	..-.
	G	--.
	H	....
	I	..
	J	.---
	K	-.-
	L	.-..
	M	--
	N	-.
	O	---
	P	.--.
	Q	--.-
	R	.-.
	S	...
	T	-
	U	..-
	V	...-
	W	.--
	X	-..-
	Y	-.--
	Z	--..
	0	-----
	1	.----
	2	..---
	3	...--
	4	....-
	5	.....
	6	-....
	7	--...
	8	---..
	9	----.),
	# russian
  qw( 
        EH	..-..  
  	YU	..--  
	YA	.-.- 
	CHEH	---.
	SHA	---- 
        ),
	# japanese (WABUN) (not done, needs support for 
        # escaping sequences DO & SN 
  qw( 
        )
  } );
  # &Auml;	.-.-
  # &Ouml;	---.	
  # &Uuml;	..--
  # adash	.--.-
  # angstroem 	.--.-	 (same as adash? huh?)
  # ch		----
  # Edash	..-..
  # N ntilde	--.--
  }
  
#############################################################################

=head1 NAME

Convert::Morse - Package to convert between ASCII text and MORSE alphabet.

=head1 SYNOPSIS

    use Convert::Morse qw(as_ascii as_morse is_morsable);

    print as_ascii('.... . .-.. .-.. ---  -- --- .-. ... .'),"\n";
						 # 'Helo Morse'
    print as_morse('Perl?'),"\n";		 # '.--. . .-. .-.. ..--..'
    print "Yes!\n" if is_morsable('Helo Perl.'); # print "Yes!"

=head1 REQUIRES

perl5.6.0, Exporter

=head1 EXPORTS

Exports nothing on default, but can export C<as_ascii()> and C<as_morse()>.

=head1 DESCRIPTION

This module lets you convert between normal ASCII text and international
Morse code. You can redefine the token sets, if you like.

=head2 INPUT

ASCII text can have both lower and upper case, it will be converted to
upper case prior to converting.

Morse code input consists of dashes C<'-'> and dots C<'.'>. The elements
B<MUST NOT> to have spaces between, e.g. A is C<'.-'> and not C<'. -'>.
Characters B<MUST> have at least one space between. Additonal spaces are
left over to indicate word boundaries. This means C<'.- -...'> means
'AB' and and C<'.-  -...'> means 'A B'.

The conversion routines are designed to be stable and ignore/skip unknown
input, so that you can write:

	print as_ascii('Hello -- --- .-. ... .  Perl!');

beware, though, a single '.' or '-' at the end will be interpreted as '. ' 
respective '- ' and thus become 'E' or 'T'. Use C<Convert::Morse::error()>
to check wether all went ok or not.

=head2 OUTPUT

The output will always consist of upper case letters or, in case of 
C<as_morse()>, of C<[-. ]>.

=head2 ERRORS

Unknown tokens in the input are ignored/skipped. In these cases you get 
the last error message with C<Convert::Morse::error()>. 

=head1 FUNCTIONS

=head2 B<as_ascii()>

            as_ascii();

Convert a Morse code text consisting of dashes and dots to ASCII.

=head2 B<as_morse()>

            as_morse();

Convert a ASCII text to Morse code text consisting of dashes, dots and spaces.

=head2 B<is_morse()>

            is_morse();

Return wether input is a true Morse code string or not.

=head2 B<is_morsable()>

            is_morseable();

Return wether input can be completely expressed as Morse code or not.

=head2 B<error()>

            error();

Returns the last error message or undef when no error occured.

=head1 LIMITATIONS

Can not yet do Japanese code nor German Umlaute. 

=head1 BUGS

None known yet.

=head1 AUTHOR

Tels http://bloodgate.com in late 2000.

=cut

1;
