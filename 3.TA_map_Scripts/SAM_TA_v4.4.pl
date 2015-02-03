#!/usr/bin/perl
## version 4. The middle 80% of the insertion were counted.
#v4.3, add $file name to each file.
#v4.4  calculate percentage of mapped/all_reads
# test the git services.
use strict;use warnings;
# git test n2
#
# git test n3
#
die "perl $0 SAM EIB202_TA_v2 \n" unless @ARGV == 2;
print "\n=============Begining the PERL $0 ================\n";
#obtain the file name
#especially for "../***/***.sam" file.
#
#$ARGV[0] =~ /\.\.\/.*\/(.*?).sam/;
$ARGV[0] =~ /(.*)\/(.*)\.sam$/;

my $file = $2;
print "SAMFILE->$ARGV[0]\n";
print "FileName(output)= \"$file\"\n";
#print "filename = $file\n";

my $reads = "Reads_".$file."\.atm";
print "\$Reads = \"$reads\"\n";
my $genome = "Genome_".$file;
my $summary = "Summary_".$file;
my $tag_insrt = "Tag_".$file;

open SAM,"$ARGV[0]" or die "no sam \n";
open TA,"$ARGV[1]" or die "no TA\n";#genome's all TA sites
open OUT1,">$reads" or die "no out\n";
open OUT2,">$genome" or die "no out2\n";
open SUM,">$summary" or die "no sum\n";
open TAG,">$tag_insrt" or die "no tag insrt file";

# Find reads of mulit-copy insertion
my %cop;
while (<SAM>){
    chomp;
    my @line = split/\t/;
    $cop{$line[0]}++;  
}

# Find exact insertion site
close SAM;
open SAM,"$ARGV[0]" or die "no sam \n";
my %pos;
my (%nTA,$multi,$unq);
$multi = 0;

while (<TA>){
    chomp;
    my @line = split/\t/;

# give 0 to null insertion sites.
    $nTA{$line[1]}++;#avoid counting overlapping sites 
}

my $unmapped = 0;
my $No_mapped = 0; # all the uniquely mapped sites

while (<SAM>){
    chomp;
    my @line = split/\t/;
    if ($cop{$line[0]} == 1)
    { #only unique insert is mapped
        $unq++;
    	if ($line[1] eq "+")
        {
			my $lc = $line[3] + 1;
			$pos{$lc}{0} += 1;
            if (! exists $nTA{$lc})
                {
                    $unmapped++;                
                }
		}
		if ($line[1] eq "-")
            {
        	    my $lc = $line[3]-1+length($line[4]);
        	    $pos{$lc}{1} +=1; 
                if (! exists $nTA{$lc})
                {
                    $unmapped++;                
                }
    		}
    }
    else #insertion in multi-copy sites
    {
        $multi++;
    }
}
print "\nInsertions in multi-copy sites: $multi\n";

$No_mapped = values %pos;

# calculation all +/- 
print OUT1 "Insertion_site\t\+$file\t\-$file\tall_$file\n";
my $mapped_reads;

for my $si (sort keys %pos)
	{
		exists $pos{$si}{0}? (1):($pos{$si}{0}=0);
		exists $pos{$si}{1}? (1):($pos{$si}{1}=0);

		$pos{$si}{2} = $pos{$si}{0}+$pos{$si}{1};
		$mapped_reads += $pos{$si}{2};
	}

for my $si (sort by_number keys %pos)
	{
		if ($pos{$si}{1} == 0)
		{
			print OUT1 $si,"\t",$pos{$si}{0},"\t",$pos{$si}{1},"\t",$pos{$si}{2},"\n";
		}
		else
		{
			print OUT1 $si,"\t",$pos{$si}{0},"\t","\-",$pos{$si}{1},"\t",$pos{$si}{2},"\n";
		}

	}

# Map location to TA sites in genome

my $n_null;
my $ln;
print OUT2 "No.\tStart\tEnd\tLength\ttag_$file\t\+_$file\t\-_$file\tAll_Insertion_$file\n";

close TA;
open TA,$ARGV[1] or die "cannot open TA\n";

my %lnTA; 
while (<TA>){
    chomp;
    my @line = split/\t/;
    $lnTA{$line[1]}++; #avoid count overlap TA sites.
    if (($lnTA{$line[1]} == 1) && ($line[1] > 0)) 
    {
        $ln++; #all TA on genome
    }

# give 0 to null insertion sites.
#avoid counting overlapping sites 
    if((! exists $pos{$line[1]}{2}) && $nTA{$line[1]} == 1)
    {
        $pos{$line[1]}{2} = 0;
        $n_null += 1; # Un-inserted TA sites.
    }

 (exists $pos{$line[1]}{0}) ? (1):($pos{$line[1]}{0} = 0);
 (exists $pos{$line[1]}{1}) ? (1):($pos{$line[1]}{1} = 0);
 (exists $pos{$line[1]}{2}) ? (1):($pos{$line[1]}{2} = 0);

    print OUT2 join("\t",@line),"\t",$pos{$line[1]}{0},"\t",$pos{$line[1]}{1},"\t",$pos{$line[1]}{2},"\n";    
}
   
#find unTA sites from .SAM
close SAM;
open SAM,"$ARGV[0]" or die "no sam \n";

# TA coverage
(my $rate) = (($ln-$n_null)/$ln)*100; #Percentage of TA insertion
(my $n_insert) = $ln-$n_null;					#Number of insertion TA sites.
my $R_insert = sprintf ("%.2f%%\n",$rate);

#insertion in Non multi copy genes(Successful Insertion Reads)
my $R_unq = sprintf ("%.2f%%\n",($unq/($unq+$multi)*100));

# No.Reads for each tag(gene/intergenetic)
close OUT2;
open OUT2,$genome or die "no out2\n";

<OUT2>;
my (%N_insert,$mapped);
$mapped = 0;
%N_insert = ();

while(<OUT2>){
       chomp;
       my @line = split/\t/;
	   #$N_insert{$line[4]}{0}=$N_insert{$line[4]}{1}=$N_insert{$line[4]}{2}=$N_insert{$line[4]}{3}=0;# initialization, {0}{1},{2},{3} for all,F 10%,E 10% and middle 80%.
	   (exists $N_insert{$line[4]}{0}) ? (1):($N_insert{$line[4]}{0}=0);
       $N_insert{$line[4]}{0} += $line[9];
       $mapped += $line[9];
		#may have warning because of the null TA fragments.
		##count the 10% end.
	   if ($line[5]<0.1)
	   {
           (exists $N_insert{$line[4]}{1}) || ($N_insert{$line[4]}{1}=0);
           $N_insert{$line[4]}{1}+=$line[9];#first 10%
	   }
	   elsif($line[5]>0.9)
	   {
           exists $N_insert{$line[4]}{2}? (1):($N_insert{$line[4]}{2}=0);
		   $N_insert{$line[4]}{2}+=$line[9];#end 10%
	   }
	   else
	   {
           exists $N_insert{$line[4]}{3}? (1):($N_insert{$line[4]}{3}=0);
		   $N_insert{$line[4]}{3}+=$line[9];#middle 80%
	   }
   }

my $R_align = sprintf ("%.2f%%\n",($mapped_reads*100/($mapped_reads+$unmapped)));

# summary Results.
print SUM "Results for: $file\nTA coverage\n";
print SUM "No.TA Null\t$n_null\n";
print SUM "No.TA insertion\t$n_insert\n";
print SUM "TA Insertion ratio\t$R_insert\n\n";
print SUM "Mapped Reads\n";
print SUM "No. Uniquely mapped_reads(all + and -) \t $mapped_reads\n";
print SUM "No. uniquely mapped reads(.SAM alignment,same as the former one) \t $unq\n";
# all reads in genome(calculate once more)
print SUM "No. Reads in Multi-site\t $multi\n";
print SUM "No. Unmapped Alignments (0 is preferred)\t",$unmapped,"\n";
#print SUM "No. mapped reads from SAM(unique)\t", $No_mapped,"\n";
print SUM "No. All mapped reads(include multi-site)\t",($unq+$multi),"\n";
print SUM "Ratio of mapped alignment\t$R_align\n";
print SUM "Ratio of uniquely mapped\t$R_unq\n\n";
print SUM "No.Total Reads for Gene&Inter(maybe more than mapped genes,due to overlap genes)\t$mapped\n";

#print No. Each tag's(gene&intergene) insertion

print TAG "tag_$file\tall insertion_$file\tbegin_10%_$file\tend_10%_$file\tMiddle_80%_$file\n";

foreach my $i (sort keys %N_insert)
	{
		exists $N_insert{$i}{1} || ($N_insert{$i}{1} = 0);
		exists $N_insert{$i}{2} || ($N_insert{$i}{2} = 0);
		exists $N_insert{$i}{3} || ($N_insert{$i}{3} = 0);

		if (exists $N_insert{$i}{0})
		{
	    print TAG $i,"\t",$N_insert{$i}{0},"\t",$N_insert{$i}{1},"\t",$N_insert{$i}{2},"\t",$N_insert{$i}{3},"\n";
		}
	}

#append no TA site to tag file.
my $sum2 = $tag_insrt."_all";
system("cat $tag_insrt NO_TA >$sum2");

sub by_number {$a <=> $b}
