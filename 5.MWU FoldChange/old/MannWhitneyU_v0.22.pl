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
my $mwu = "Comb_MWU_all.xls";my $fc="'Comb_FoldChange_all_Out_In.xls'";
open OUT2,">",$mwu or die "cannot create combined output of MWU($.)\n";
open OUT3,">",$fc or die "cannot create foldchange file(40)\n";


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
open my $O1,">Ave_MWU.xls" or die "cannot create mwu file($.)\n";
open my $O2,">Ave_FoldChange_out_in.xls" or die "cannnot create foldchange file($.)\n";

close OUT2;close OUT3;
open my $MWU,$mwu or die "cannot open mwu output";
open my $FC,$fc or die "cannot open foldchange output";
print "#replicate?(2,3):\n";
chomp(my $r = <STDIN>);
&avge($MWU,$O1,"4");
&avge($FC,$O2,"5");

sub avge{
	my $in = $_[0];
	my $out = $_[1];
	while(<$in>){
	chomp;
	my @line = split/\t/;
	my @ele = @line;
	my ($ave,$i);
	$i = $_[2];
	print $out "$line[0]\t$line[1]\t$line[2]\t$line[3]";
	for($i=4;exists $line[$i];$i=$i+$r)
	{
		my $j = 0;
		($line[$i]=~/^[0-9]/) ? ($j++):($ele[$i]=0);
		($line[$i+1]=~/^[0-9]/) ? ($j++):($ele[$i+1]=0);
		if ($r == 3 && $j != 0)
		{
			($line[$i+2]=~/^[0-9]/) ? ($j++):($ele[$i+2]=0);
			print $out "\t",sprintf("%.5f",(($ele[$i]+$ele[$i+1]+$ele[$i+2])/$j));
		}
		elsif($j !=0 )
		{
			print $out "\t",sprintf("%.5f",(($ele[$i]+$ele[$i+1])/$j));
		
		}
		else
		{
			print $out "\t",$line[$i],"--",$line[$i+$r-1];
		}
	}
	print $out "\n";	
}
}


`mkdir tmp_mwu`;
`mv MWU_* tmp_mwu`;

