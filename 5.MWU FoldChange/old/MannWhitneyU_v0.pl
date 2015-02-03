#! usr/bin/perl
## batch process by mannwhite U test for "Genome files"
#
use strict;use warnings;

die "Usage:perl $0 1.Dir_of_GenomeFiles 2.MannWhite_script(mannwhitneyu_YGH.py) 3.Gene_List(1_EIB202_genelist) 4.Reference(Genome...)\n" unless @ARGV==4;

my $DIR_PATH = $ARGV[0];
opendir TEMP, ${DIR_PATH} || die "Can not open this directory";
my @filelist = readdir TEMP; 

my ($Genome_file,$output);
foreach (@filelist) {
    if (/Genome.*/) 
	{
		print "================Locating the Genomefiles====================\n";
		/Genome_(.*)/;
		$output = "MWU_".$1;
		open OUT,">$output" or die "cannot open out\n";
		print OUT "Tag\tgene\tTA\tU($1)\tp_val($1)\tCountRatio($1)\n";
		$Genome_file=$ARGV[0]."/".$_;
		print "Genome file:->$Genome_file\n";
		#print "\$_====",$_,"\n";
		system "python $ARGV[1] $ARGV[2] $ARGV[3] '$Genome_file' >>$output";
        print "\n---------- Genome FILE: $Genome_file finished----------------\n\n";
	}
  }

## combine all the MWU output files

my $pas="pasted_MWU_all";
`paste MWU* >$pas`;

open PAS,$pas or die "cannot open pasted results\n";
open OUT2,">Comb_MWU_all.xls" or die "cannot create combined output of MWU\n";

while(<PAS>){
	chomp;
	my @line = split/\t/;
	print OUT2 "$line[0]\t$line[1]\t$line[2]\t";
	my $i;
	for ($i = 4;exists $line[$i];$i=$i+6)
	{
		#my $ii=$i+1;
		print OUT2 "$line[$i]\t$line[$i+1]\t";
	}
	print OUT2 "\n";

}



