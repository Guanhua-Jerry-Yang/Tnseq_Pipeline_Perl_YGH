#!perl
use strict; use warnings;
die "Usage: Perl $0 Directory(Tag)\n" unless @ARGV == 1;
use List::AllUtils qw(min max);

`mkdir $ARGV[0]tag_all_folder`;
`mv *all $ARGV[0]tag_all_folder/`;
my $out;
my $pas="TAG_paste";
`paste $ARGV[0]Tag* > $pas`;

#main
my $f1= "ALL_Insert";
my $f2= "Middle80\%_Insert";

&comb(1,$f1); #row and filename
&norm($f1);
print "====$out finished===\n\n";

&comb(4,$f2);
&norm($f2);
print "====$out finished===\n\n";


sub comb {
$out = "$_[1].out";
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
	open OUT2,">$_[0].norm" or die "cannot out out2\n";
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
	print "SUM value: @sum\n";
#step2: calculate the index by the maximum value
	my $max = max @sum;
	print "Max is $max\n";
	my @idx;$idx[0]="NA";
	for ($i=1;exists $sum[$i];$i++)
	{
		$idx[$i] = $max/$sum[$i];
	}
	print "Index value: @idx\n";
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
}
