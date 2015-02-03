#!perl
use strict;
die "Usage:perl $0 1.dir_trimmed files 2.Reference(../EIB202)\n" unless @ARGV==2;

my $sfx = "_trimmed\.fq";

&bowtie($sfx);

sub bowtie {
my $DIR_PATH = $ARGV[0];
opendir TEMP, ${DIR_PATH} || die "Can not open this directory";
my @filelist = readdir TEMP; 
my $file;
foreach (@filelist) 
	{
    	if (/$_[0]/) #suffix of file (eg .fastq) 
		{
		print "\n\n================Begining ====================\n";
		$file=$ARGV[0].$_;
		/(.*)$_[0]/;# obtain out filename
		my $out = $1."\.sam";
		print "Fastq file -> $file\n";
		print "Output file-> $out\n\n";
		#print "\$_====",$_,"\n";
		system "bowtie -v 3 -a --best --strata -m 1 -q $ARGV[1] '$file' $out";
		#print "***BOWTIE CMD: STDOUT\n";
		# bowtie default condition:-O for minimum length,-e for error rate
		print "\n---------- Finished for: $file ----------------\n\n";
		}
	}
}	
