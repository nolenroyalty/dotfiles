#!/usr/bin/perl
# Version : v1_1
# Date    : 2007-06-16 00:31:12

use warnings;
use strict;
use File::Temp qw/ tmpnam /;
use Getopt::Std;

our %opts;

###defaults###
my $debug            = 0;
my $test             = 0;
my $blacklist        = "";
my $man_cmd          = q!(man _MODULE_ | col -b ) 2>/dev/null!;
my $pod_cmd          = q!(perldoc  _MODULE_ | col -b ) 2>/dev/null!;
my $ctags_cmd        = q!ctags -f- --perl-kinds=s _MODULE_ 2>/dev/null!;
my $extensions       = 0;
my $recursive        = 1;
my $re_custom        = "";
#############
getopts('b:dt:m:c:p:Reu:',\%opts) or HELP_MESSAGE();
$debug               = $opts{'d'} if $opts{'d'};
$test                = $opts{'t'} if $opts{'t'};
$blacklist           = $opts{'b'} if $opts{'b'};
$man_cmd             = $opts{'m'} if $opts{'m'};
$pod_cmd             = $opts{'p'} if $opts{'p'};
$ctags_cmd           = $opts{'c'} if $opts{'c'};
$recursive           =!$opts{'R'} if $opts{'R'};
$extensions          =!$opts{'e'} if $opts{'e'};
$re_custom           =$opts{'u'} if $opts{'u'};


if ( $debug )
{
  print <<EOF
Options :
debug             : $debug
test              : $test
blacklist         : $blacklist
man_cmd           : $man_cmd
pod_cmd           : $pod_cmd
ctags_cmd         : $ctags_cmd
recursive         : $recursive
re_custom         : $re_custom

EOF
  ;
}

my $result= { };
my $main_module ;

my $re_word   = qr/(?:\S+)/;
my $re_hash   = qr/{[^},]*}/;
my $re_array  = qr/\[[^\],]*\]/;
my $re_string = qr/(?:"[^"]*"|'[^']*')/;
my $re_storage= qr/(?:\\?(?:\$|%|@|\*|&))/;
my $re_ident  = qr/(?:\w+)/;

my $re_var    = qr/(?:$re_storage$re_ident)/;
my $re_ref    = qr/(?:(?:$re_ident|$re_string)\s*=>\s*(?:$re_string|$re_hash|$re_array))/;
my $re_arg    = qr/(?:(?:\[?\s*(?:$re_var|$re_ident|$re_ref|$re_string|$re_word)\s*\]?)|$re_ident\s*\|\s*$re_ident)/;
#my $re_arg    = qr/(?:(?:\[?\s*(?:$re_word)\s*\]?)|$re_word\s*\|\s*$re_word)/;
my $re_args   = qr/(?:\(\s*(?:$re_arg\s*,\s*)*(?:$re_arg)?\s*\))/;
my $re_assign = qr/(?:(?:my\s+)?(?:$re_var|$re_args|$re_ident)\s*=)/;

if ( $re_custom )
{
  $re_custom = qr/($re_custom)/;
}
############################################
HELP_MESSAGE() if not @ARGV and not $test; #
$main_module = shift;
main($main_module) unless $test;           #
vim_print($result) unless $debug or $test; #
debug_print($result,0) if $debug;          #
test_run($test) if $test;                  #
exit 0;                                    #
############################################


sub main
{
  my $module = shift;
  $module =~ s/^\s*(\S*)\s*/$1/;

  return if not $module =~ /[A-Z].*/;


  my $dirsep = "/";
  my $os = $^O;
  $dirsep = '\\' if $os =~ /msdos|win/i;

  my $file = $module;
  $file =~ s-::-$dirsep-g;
  my ($pod,$pm) ;
  foreach ( @INC )
  {
    my $try = "$_$dirsep$file";
    if ( -r "$try.pod" )
    {
      $pod = "$try.pod";
    }
    if ( -r "$try.pm" )
    {
      $pm = "$try.pm";
    }
    last if $pm && $pod;
  }

  my $isa_expr = '@'."${module}::ISA";
  my @isa = eval(" use $module; $isa_expr; ");

  # $1 - whole thing ('line')
  # $2 - identifier  (key)
  # $3 - args?       ('args')
  my $re_instance_method = qr/^\s*($re_assign?\s*\$$re_ident\s*->\s*($re_ident)\s*($re_args?))\s*;?\s*(?:#.*)?$/;
  my $re_class_method    = qr/^\s*($re_assign?\s*$module\s*->\s*($re_ident)\s*($re_args)?)\s*;?\s*(?:#.*)?$/;
  my $re_class_var       = qr/^\s*($re_storage$module\s*::\s*($re_ident)\s*(?:=.*)?)(?:#.*)?$/;
  my $re_func            = qr/^\s*($re_assign?\s*(?:${module}::)?($re_ident)\s*($re_args))\s*;?\s*(?:#.*)?$/;
  my $re_unknown         = qr/(^\s*([a-z]\w*)\s*)$/;
  #




  my $cmd ;
  my  @manual ;
  if (  $pod )
  {
    $cmd = $pod_cmd;
    $cmd =~ s/_MODULE_/$pod/g;
    @manual= qx($cmd);
  }
  elsif ( $pm )
  {
    $cmd = $pod_cmd;
    $cmd =~ s/_MODULE_/$pm/g;
    @manual= qx($cmd);
  }
  if ( $? || @manual < 10 )
  {
    $cmd = $man_cmd;
    $cmd =~ s/_MODULE_/$module/g;
    @manual= qx($cmd);
  }
  return if not @manual;

  $result->{$module} = {
    instance_methods => {},
    class_methods => {},
    class_vars => {},
    functions => {},
    unknown => {},
    from_exporter => {},
    from_ctags => {},
    isa => join( ",", @isa )
  };

  $result->{$module}->{'custom'} = {} ;

  my $lnum = 0;
  my $in_method_section = 0;
  foreach ( @manual )
  {
    ++$lnum;
    chomp;
    next if /^\s*$/;
    if ( /^\s*METHODS\s*$/ )
    {
      $in_method_section = 1;
    }
    elsif ( /^\s*[A-Z]*\s*$/ )
    {
      $in_method_section = 0;
    }

    if ( /$re_instance_method/ )
    {
      next if $module ne $main_module and $result->{$main_module}->{'instance_methods'}->{$2};
      make_entry($lnum,$result->{$module}->{'instance_methods'},$1,$2,$3);
    }
    elsif ( /$re_class_method/ )
    {
      next if $module ne $main_module and $result->{$main_module}->{'class_methods'}->{$2};
      make_entry($lnum,$result->{$module}->{'class_methods'},$1,$2,$3);
    }
    elsif ( /$re_class_var/ )
    {
      next if $module ne $main_module and $result->{$main_module}->{'class_vars'}->{$2};
      make_entry($lnum,$result->{$module}->{'class_vars'},$1,$2);
    }
    elsif ( /$re_func/ )
    {
      if ( $in_method_section )
      {
	make_entry($lnum,$result->{$module}->{'class_methods'},$1,$2,$3);
      }
      else
      {
	make_entry($lnum,$result->{$module}->{'functions'},$1,$2,$3);
      }
    }
    elsif ( /$re_unknown/ )
    {
      make_entry($lnum,$result->{$module}->{'unknown'},$1,$2);
    } 
    if ( $re_custom && /$re_custom/ )
    {
      if ( $2 )
      {
	my $token2 = $2 ;
	$token2 =~ s/'/"/g;
	make_entry($lnum,$result->{$module}->{'custom'},$_,$token2);
      }
      else
      {
	my $token1 = $1;
	$token1 =~ s/'/"/g;
	make_entry($lnum,$result->{$module}->{'custom'},$_,$token1);
      }
    }
  }
  $result->{$module}->{'export'} = {};
  $result->{$module}->{'export'}->{'tags'} = {};
  $result->{$module}->{'export'}->{'exported'} = {};
  $result->{$module}->{'export'}->{'ok'} = {};

  get_exporter_infos($module);
  for ( keys %{$result->{$module}->{'export'}->{'exported'}} )
  {
    $result->{$module}->{'from_exporter'}->{$_} = {};
  }
  for ( keys %{$result->{$module}->{'export'}->{'ok'}} )
  {
    next if $result->{$module}->{'from_exporter'}->{$_};
    $result->{$module}->{'from_exporter'}->{$_} = {};
  }

  my $fname  = tmpnam();
  $result->{$module}->{'manual'}  = $fname;
  unless ( $debug )
  {
    open ( MAN,"> $fname" );
    print MAN join("\n",@manual);
    close MAN;
  }

  if ( $extensions )
  {
    extensions($module,$pod,$pm);
  }

  unless ( $test || !$recursive)
  {
    foreach ( @isa )
    {
      next if $result->{$_};
      next if $blacklist =~ /$_( |,|$)/;
      main($_);
    }
  }
}

sub get_exporter_infos
{
  my $module = shift;
  return if not $module;
  my @exports =  eval("use $module; \@$module\::EXPORTS;");
  my @export_ok =  eval("use $module;\@$module\::EXPORT_OK;");
  my @export_tags_keys = eval("use $module;keys \%$module\::EXPORT_TAGS;");
  my %export_tags = ();
  return if not @export_ok;
  foreach ( @export_tags_keys )
  {
    $export_tags{$_} = eval("use $module; \$$module\::EXPORT_TAGS{$_};");
  }

  foreach ( @export_ok )
  {
    $result->{$module}->{'export'}->{'ok'}->{$_} = 1;
  }
  foreach ( @exports )
  {
    $result->{$module}->{'export'}->{'exported'}->{$_} = 1;
  }
  $result->{$module}->{'export'}->{'tags'} = {};
  while ((my ( $k,$v )) = each %export_tags )
  {
    $result->{$module}->{'export'}->{'tags'}->{$k} = join(',',@{$v});
  }
}

sub vim_print
{
  my $thing = shift;
  if ( ref($thing) eq "HASH" )
  {
    my @keys = keys %{$thing};
    print "{";
    while ( @keys )
    {
      my $key = shift @keys;
      print "'$key':";
      vim_print($thing->{$key});
      print "," if @keys;
    }
    print "}";
  }
  elsif (!ref($thing))
  {
    print "'$thing'";
  }
  else
  {
    die "vim_print : bad ref found -> ",ref($thing),"\n" ;
  }
}
sub debug_print
{
  my @modules = keys(%{$result});
  while ( @modules )
  {
    local $\="\n";
    my $mod = shift @modules;
    print "$mod";
    print "="x length($mod);
    print "\@ISA = [ $result->{$mod}->{'isa'} ]\n";
    my @kinds = keys(%{$result->{$mod}});
    while ( @kinds )
    {
      my $kind = shift @kinds;
      next if ref($result->{$mod}->{$kind}) ne 'HASH';
      next if not %{$result->{$mod}->{$kind}};
      print "$kind";
      print "-" x length($kind);
      my @members = keys %{$result->{$mod}->{$kind}};
      while ( @members )
      {
	my $member = shift @members;
	my $lnum = $result->{$mod}->{$kind}->{$member}->{'lnum'};
	my $line = $result->{$mod}->{$kind}->{$member}->{'line'};
	print "$member";
	print "$lnum $line" if $lnum and $line;
      }
      print "";
    }
  }
}
sub make_entry
{
  my ($lnum,$hash,$line,$ident,$args ) = @_;
  if ( $ident )
  {
    if ( $hash->{$ident} &&  ( !$args || first_args_are_nicer($hash->{$ident}->{'args'},$args)))
    {
      return $hash->{$ident};
    }

    $line =~ s/'/"/g;
    $args =~ s/'/"/g if $args;
    ${$hash}{$ident} = { line => $line };
    ${$hash}{$ident}->{'lnum'} = $lnum;
    ${$hash}{$ident}->{'args'} = $args if $args;
    return ${$hash}{$ident};
  }
  return undef;
}
sub extensions
{
  my ( $module,$pod,$pm ) = @_;
  check_tags($module,$pm) if $pm;
  #other ideas :
  #strings(module.so) | grep /^Usage:?$module::member(args)/
    #if /DynaLoader/ 
  #ls ../$module/*.al
    #if /AutoLoader/
}
sub check_tags
{
  my ($module,$pm) = @_;

  my $cmd = $ctags_cmd;
  $cmd =~ s/_MODULE_/$pm/g;
  my @tags = qx($cmd);
  foreach ( @tags )
  {
    chomp;
    next if /^(_|!|[A-Z]+\s)/;
    /^(\w*).*/;
    my $member = $1;
    if ( not 
      $result->{$module}->{'functions'}->{$member}
      || $result->{$module}->{'instance_methods'}->{$member}
      || $result->{$module}->{'class_methods'}->{$member} 
    )
    {
      $result->{$module}->{'from_ctags'}->{$member} = {} ;
    }
  }
}
sub arrity
{
  return undef unless shift =~ /^\(([^)]*)\)/;
  my $args = $1;
  my @args = split /,/,$args ;
  return @args;
}
sub first_args_are_nicer
{
  my $first = shift;
  my $second = shift;

  return 1 if not $second;
  return 0 if not $first;

  my @first =  split(/,/,$first);
  my @second = split(/,/,$second);

  return $#first > $#second unless $#first == $#second;

  return 1 if $#first < 0;

  return 0 if $second =~ /\[[^\]]*\]/;
  return 1 if $first  =~ /\[[^\]]*\]/;

  return 0 if $second =~ /.*\|.*/;
  return 1 if $first  =~ /.*\|.*/;

  while ( @first )
  {
    my $second = shift @second;
    my $first = shift @first;
    return 1 if $second =~ /^\(?\d|"|'/ ;
    return 0 if $first  =~ /^\(?\d|"|'/ ;
    return 1 if $second =~ /^\(?\w/ ;
    return 0 if $first  =~ /^\(?\w/ ;
  }
  return 1;
}
sub member
{
  my $key = shift;
  my $array = shift;
  foreach ( @{$array} )
  {
    return 1 if $_ eq $key;
  }
  return 0;
}

sub HELP_MESSAGE
{
  print <<EOF
Usage : $0 [OPTIONS] MODULE

-b [blacklist]   Blank separated list of modules that will be ignored.
-d               Debugoutput instead of vim hash.
-m [syscmd]      Command to access a manpage.
-p [syscmd]      Command to translate pod to text.
-c [syscmd]      Command to create tags file.
-R               Non recursive.
-u [regex]       Additional regex to use ( as 'custom') .

All commands must write to stdout. 
Any '_MODULE_' string will be substituted for the current module.

EOF
  ;
  exit 1;
}

sub read_test_file
{
  my ($file,$hash) = @_;
  open (TEST ,$file) or die "Cant open testfile\n";
  my @file = <TEST>;
  close TEST;
  my $ref;
  my $module;
  while ( @file )
  {
    my $line = shift @file;
    chomp $line;
    $line =~ s/^\s*(\S*)\s*$/$1/;
    die "No empty lines allowed" if $line =~ /^\s*$/;

    if ( $line =~ /\[module\]/ )
    {
      $module = shift @file;
      chomp($module);
      $module =~ s/^\s*(\S*)\s*$/$1/;
      $hash->{$module}= {};
      $hash->{$module}->{'instance_methods'} = {};
      $hash->{$module}->{'class_methods'} = {};
      $hash->{$module}->{'class_vars'} = {};
      $hash->{$module}->{'functions'} = {};
    }
    elsif ( $line =~ /\[([^\]]+)\]/ )
    {
      $ref = $hash->{$module}->{$1};
    }
    else
    {
      die "Malformed testfile\n" if !$ref ;
      $ref->{$line}=1;
    }
  }
}
sub debug_print_test_file
{
  my $hash = shift;
  my @modules = keys %{$hash};
  while ( @modules )
  {
    my $module = shift @modules;
    print "[module]\n";
    print "$module\n";
    my @members = keys ( %{$hash->{$module}} );
    while ( @members )
    {
      my $member = shift @members;
      print "[$member]\n";
      my @ident = keys %{$hash->{$module}->{$member}};
      while ( @ident )
      {
	print shift @ident,"\n";
      }
    }
  }
}
sub diff_keys
{
  my ( $h1,$h2 ) = @_;
  my @not_in_first = ();
  my @not_in_second =();
  my @k1 = sort (keys %{$h1});
  my @k2 = sort (keys %{$h2});
  my ( $i,$j ) = (0,0);

  while ( $i <= $#k1 && $j <= $#k2 )
  {
    if ( $k1[$i] eq $k2[$j] )
    {
      ++$i;
      ++$j;
    }
    elsif ( $k1[$i] lt $k2[$j] )
    {
      while( $i <= $#k1 && $k1[$i] lt $k2[$j])
      {
	push @not_in_second,$k1[$i++];
      }
    }
    else
    {
      while( $j <= $#k2 && $k2[$j] lt $k1[$i] )
      {
	push @not_in_first,$k2[$j++];
      }
    }
  }
  while ( $i <= $#k1 )
  {
    push @not_in_second,$k1[$i++];
  }
  while ( $j <= $#k2 )
  {
    push @not_in_first,$k2[$j++];
  }
  my %res = (
    not_in_second => \@not_in_second,
    not_in_first => \@not_in_first
  );
  return \%res;
}
sub test_run
{
  my $file = shift;
  my $missed = 0;
  my $false  = 0;
  my $total = 0;

  $debug=0;
  $blacklist="";

  my %modules;
  read_test_file($file,\%modules);
  foreach my $mod ( keys %modules )
  {
    $result= { };
    main($mod);

    print "=" x length($mod),"\n";
    print "|$mod|\n\n";

    my $m_missed = 0;
    my $m_false  = 0;
    my $m_total  = 0;
    foreach ( keys %{$modules{$mod}} )
    {
      my $diff    = diff_keys($modules{$mod}->{$_},$result->{$mod}->{$_});
      my $t_false = $#{$diff->{'not_in_first'}} + 1;
      my $t_missed= $#{$diff->{'not_in_second'}} + 1;
      my $t_total = (keys(%{$modules{$mod}->{$_}}));
      $m_false    += $t_false;
      $m_missed   += $t_missed;
      $m_total    += $t_total;

      print "$_:\n";
      print "-" x length("$_:"),"\n";
      print "missed: $t_missed/$t_total  ";
      printf("%.2f%%\n",100.*$t_missed/$t_total) if $t_total > 0;
      foreach( @{$diff->{'not_in_second'}} )
      {
	print ("\t$_\n");
      }
      print "\n";
      print "false: $t_false/$t_total  ";
      printf("%.2f%%\n",100.*$t_false/$t_total) if $t_total > 0;
      foreach( @{$diff->{'not_in_first'}} )
      {
	print ("\t$_\n");
      }
      print "\n\n";
    }
    print "Overall : $m_total members\n";
    print "missed  : $m_missed ";
    printf("%.2f%%\n",100.*$m_missed/$m_total) if $m_total > 0;
    print "false   : $m_false ";
    printf("%.2f%%\n",100.*$m_false/$m_total) if $m_total > 0;
    print "=" x length($mod),"\n";
    print "\n";

    $total+=$m_total;
    $missed+=$m_missed;
    $false+=$m_false;
  }

  print "TOTAL : $total members\n";
  print "missed  : $missed  ";
  printf("%.2f%%\n",100.*$missed/$total) if $total > 0;
  print "false   : $false ";
  printf("%.2f%%\n",100.*$false/$total) if $total > 0;
  print "\n";
  print "\n";
}
