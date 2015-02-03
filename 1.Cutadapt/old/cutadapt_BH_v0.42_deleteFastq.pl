#!perl
##version:
#v0.1 add "rm tmp"
#v0.41 add 2 base to 5' adapter, set -O 5 -e 0.1. proved to be better than v0.3

use strict;
die "Usage:perl $0 directory\n\n!WAERING: original fastq will be deleted" unless @ARGV==1;

my ($ip,$str,$adp,$op);
# step 1: 5' trimming
$ip = "\.fastq";
$str= "g";
$adp= "CAGCCAACCTGT";
$op = "_5_tmp.fq";

&cutadapt($ip,$str,$adp,$op,$ARGV[0]);
print "\n****************step1 finished************************\n";

# step 2: 3' trimming
$ip = $op;
$str = "a";
$adp = "ATACCACGAC";
$op = "_trimmed.fq";
my $pwd="./";
&cutadapt($ip,$str,$adp,$op,$pwd);
#print "3\' Input:$ip\;Output:$op\n";
print "\n****************step2 finished************************\n";


sub cutadapt {
my $DIR_PATH = $_[4]."/";
opendir TEMP, ${DIR_PATH} || die "Can not open this directory";
my @filelist = readdir TEMP; 
my $file;
foreach (@filelist) 
	{
    	if (/$_[0]/) #suffix of file (eg .fastq) 
		{
		print "\n\n================Trimming $_[0] adapter ====================\n";
		$file=$_[4]."/".$_;
		/(.*)$_[0]/;# obtain out filename
		my $out = $1.$_[3];
		print "Fastq file ->$file\n";
		print "output file->$out\n\n";
		#print "\$_====",$_,"\n";
		system "cutadapt -$_[1] $_[2] -O 5 -e 0.1 -f fastq '$file' > $out";
		# cutadapt default condition:-O for minimum length,-e for error rate
		system "rm -v $file";
		print "\n---------- Trimming ended for: $file ----------------\n\n";
		}
	}
}

