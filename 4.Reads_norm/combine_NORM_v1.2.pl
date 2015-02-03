#!perl
use strict; use warnings;
die "Usage: Perl $0 Directory(Tag)\n!single input file MUST be on last column !\nOUTPUT:Combination of normalized files, average of replicates and STDEV\n" unless @ARGV == 1;
use List::AllUtils qw(min max);
use Statistics::Basic qw(:all nofill);

`mkdir $ARGV[0]tag_all_folder`;
`mv $ARGV[0]*all $ARGV[0]tag_all_folder/`;

my ($out,$norm_out);
my $pas="TAG_paste";
`paste $ARGV[0]Tag* > $pas`;

#main
my $f1= "Rds_ALL";
my $f2= "Rds_M80";
## unNormed rds
&comb(1,$f1);
&norm($f1);
print "\n\n#replicates(2 or 3)?:\n";
chomp(my $r = <STDIN>);
&avge($norm_out,$f1,$r);
print "\n\n====$out finished===\n\n";
# Normed rds
&comb(4,$f2);
&norm($f2);
&avge($norm_out,$f2,$r);
print "\n\n====$out finished===\n\n";


sub comb {
$out = "$_[1]_out.xls";
open OUT,">$out" or die "cannot open output\n";
open IN,$pas or die "cannot open pasted file as input\n";

while(<IN>){
	chomp;
	my @line = split/\t/;
	print OUT $line[0],"\t";
	my $i;
	for( $i=$_[0]; exists $line[$i];$i = $i+5)
		{
			print OUT "$line[$i]\t" ;
		}
	print OUT "\n";

}
print "====== Creating $out finished========\n";
close OUT;
}

sub norm {
	$norm_out = "$_[0]_norm.xls";
	open OUT2,">$norm_out" or die "cannot out out2\n";
	my $ip = $out; 
	open IP,$ip or die "cannot open $ip for norm input\n";
	my @sum;$sum[0] =0 ;
	my $i;
#step 1: calculate the sum of each column(sample)
	<IP>;
	while (<IP>){
		chomp;
		my @line = split/\t/;
		for ($i = 1;exists $line[$i];$i++)
		{
			(exists $sum[$i]) || ($sum[$i] = 0);
			$sum[$i] += $line[$i];
		}
	}
	print "\n\nSUM value: @sum\n\n";
#step2: calculate the index by the maximum value
	my $max = max @sum;
	print "\n\nMax is $max\n";
	my @idx;$idx[0]="NA";
	for ($i=1;exists $sum[$i];$i++)
	{
		$idx[$i] = $max/$sum[$i];
	}
	print "\n\nIndex value: @idx\n\n";
#step3: use  index to calculate the normalization
	close IP;
    open IP,$ip or die "cannot open pasted file as input\n";
	my $l1 = 1;
	while (<IP>){
		chomp;
		my @line = split/\t/;
		if ($l1 == 1)
		{
			print OUT2 join("\t",@line),"\n";
			$l1++;
		}
		else
		{
			print OUT2 $line[0],"\t";
			for ($i = 1;exists $line[$i];$i++)
			{
				my $normed = sprintf ("%.2f",($line[$i]*$idx[$i]));
				print OUT2 $normed,"\t";
			}
			print OUT2 "\n";
		}
}
close OUT2;
}


sub avge {
	my $out1 = $_[1]."_Ave.xls";
	open IN2,$_[0] or die "cannot open IN\n";
	open OUT3,">$out1" or die "cannot create $_[1]\n";
	my $n = 1;
	while(<IN2>){
		chomp;
		#print "\n===$_\n\n\n";
        my @line = split/\t/;
        my $i;
		#print "line====== $.\n\n";
		if ($n == 1)
		{
			print OUT3 "tag";
			#	print "line ---- @line\n";
			for ($i = 1;exists $line[$i+1];$i= $i+$r)
			{
				$line[$i] =~ s/\w$//;
				print OUT3 "\t",$line[$i],"\t$line[$i]_STDEV";
			}
			print OUT3 "\t$line[$i]\n";#last column of innput
			$n++;
		}
		else{
			#print "====line = @line\n";
			print OUT3 $line[0];
            for($i=1;exists $line[$i+1];$i=$i+$r)
            {
                if ($r == 3 )
                {
                    print OUT3 "\t",sprintf("%.1f",(($line[$i]+$line[$i+1]+$line[$i+2])/3)),"\t",sprintf("%.2f",(stddev($line[$i],$line[$i+1],$line[$i+2])));#bug: treat no insertion as "0"
               }
				else
                {
                    print OUT3 "\t",sprintf("%.1f",(($line[$i]+$line[$i+1])/2)),"\t",sprintf("%.2f",(stddev($line[$i],$line[$i+1])));
                    
                }
            }
            print OUT3 "\t$line[$i]\n";	
        }
	}
}
