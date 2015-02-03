#! perl
##version:
#v0.1 add "rm tmp"
#v0.41 add 2 base to 5' adapter, set -O 5 -e 0.1. proved to be better than v0.3
#v0.5 change the 5' adapter to 19 bp 
use strict;
die "Usage:perl $0 directory\n" unless @ARGV==1;

my ($ip,$str,$adp,$op);
# step 1: 5' trimming
$ip = "\.fastq";
$str= "g";
$adp= "GACTTATCAGCCAACCTGT";
$op = "_5_tmp.fq";
my $pm1 = "-O 17 -e 0.2 -M 53 --match-read-wildcards --discard-untrimmed -f fastq";
&cutadapt($ip,$str,$adp,$op,$ARGV[0],$pm1);
print "\n****************step1 finished************************\n";

# step 2: 3' trimming
$ip = $op;
$str = "a";
$adp = "ATACCACGAC";
$op = "_trimmed.fq";
my $pm = " -O 5 -e 0.1 -m 10 -M 53 -f fastq";
my $pwd="./";
&cutadapt($ip,$str,$adp,$op,$pwd,$pm);
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
		system "cutadapt -$_[1] $_[2] $_[5] '$file' > $out";
		# cutadapt default condition:-O for minimum length,-e for error rate
		print "\n---------- Trimming ended for: $file ----------------\n\n";
		}
	}
}

system "rm -v *_5_tmp*";
