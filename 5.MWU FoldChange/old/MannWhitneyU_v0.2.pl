#! usr/bin/perl
## batch process by mannwhite U test for "Genome files"
#
#v0.2 works with mann..v0.2.py for adding anno column.
#output 2files; ref file skipped.
use strict;use warnings;

die "Usage:perl $0 1.Dir_GenomeFiles(end with '\/') 2.MannWhite_script(mannwhitneyu_YGH.py) 3.Gene_List(1_EIB202_genelist) 4.Ref(Input's GenomeFile)\n" unless @ARGV==4;

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
		$Genome_file=$ARGV[0].$_;
		#print "\$_====",$_,"\n";
		($Genome_file eq $ARGV[3])?(next):(1);#skip reference file
		open OUT,">$output" or die "cannot open out\n";
		print "Genome file -> $Genome_file\n";
		print OUT "Tag\tgene\tanno\tTA\tU($1)\tp_val($1)\tCountRatio($1)\n";
		system "python $ARGV[1] $ARGV[2] $ARGV[3] '$Genome_file' >>$output";
        print "\n---------- Genome FILE: $Genome_file finished----------------\n\n";
	}
  }

## combine all the MWU output files

my $pas="pasted_MWU_all";
`paste MWU* >$pas`;

open PAS,$pas or die "cannot open pasted results\n";
open OUT2,">Comb_MWU_all.xls" or die "cannot create combined output of MWU\n";
open OUT3,">Comb_FoldChange_all(Out/In).xls" or die "cannot create foldchange file\n";


while(<PAS>){
	chomp;
	my @line = split/\t/;
	print OUT2 "$line[0]\t$line[1]\t$line[2]\t$line[3]";
	print OUT3 "$line[0]\t$line[1]\t$line[2]\t$line[3]";
	my $i;
	for ($i = 5;exists $line[$i];$i=$i+7)
	{
		#my $ii=$i+1;
		print OUT2 "\t$line[$i]";
	}
	print OUT2 "\n";

	my $j;
	for ($j = 6;exists $line[$j];$j=$j+7)
	{
		print OUT3 "\t$line[$j]";
	}
	print OUT3 "\n";

}


`mkdir tmp_mwu`;
`mv MWU_* tmp_mwu`;

