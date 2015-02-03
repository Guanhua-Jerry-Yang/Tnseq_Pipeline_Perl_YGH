
use strict;

die "Usage:perl $0 directory SAM_TA...pl EIB_TA_v2.file\n" unless @ARGV==3;

my $DIR_PATH = $ARGV[0];
opendir TEMP, ${DIR_PATH} || die "Can not open this directory";
my @filelist = readdir TEMP; 

my $samfile;
foreach (@filelist) {
    if (/\.sam/) 
	{
		print "================Locating the SAMfile ====================\n";
		$samfile=$ARGV[0].$_;
		print "samfile->$samfile\n";
		#print "\$_====",$_,"\n";
		system "perl $ARGV[1] '$samfile' $ARGV[2]";
        print "\n---------- SAM FILE: $samfile finished----------------\n\n";
	}
  }

