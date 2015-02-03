## v0.1 jump the headline of Genome_.. file, by if...
## This program employs a mann whitney u test to compare two trash runs
## Inputs: run analysis text file with all runs, both conditions' IGV files
## >> python mannwhitneyu.py run6analysis.txt ___.igv ____.igv

#argv[1]=genelist file for pulling out start, stop, gene name info
#argv[2]=WT combined files
#argv[3]=mutant combined reads file

import sys, random, scipy, numpy
from math import *
from scipy import stats

## DEFINE GENE NAMES, STARTS, ENDS

genes = []; genereads = {}

for line in open(sys.argv[1]):
    g = line.split('\t')
    genes.append([g[0],g[1],int(g[2]),int(g[3])])
    genereads[g[0]] = [],[]
            

## DEFINE RATIO BETWEEN TOTAL READ COUNTS AS CORRECTION

Lib1Reads = 0; Lib2Reads = 0
Lib1TA = 0; Lib2TA = 0

for line in open(sys.argv[2]):
    split = line.split('\t')
    if not (split[1].isdigit()): # jump the headline
        continue
    Lib1TA += 1
    Lib1Reads += int(split[9])

for line in open(sys.argv[3]):
    split = line.split('\t')
    if not (split[1].isdigit()): # jump the headline
        continue
    Lib2TA += 1
    Lib2Reads += int(split[9]) # if len(split)>4 and split[4].isdigit()==True:
        
ratio = float(Lib1Reads)/float(Lib2Reads)

## SET DICTIONARIES WITH GENE READS

## set first for Library 1
for line in open(sys.argv[2]):
    split = line.split('\t')
    if split[4] in genereads:
        genereads[split[4]][0].append(int(split[9]))

## set for Library 2
for line in open(sys.argv[3]):
    split = line.split('\t')
    if split[4] in genereads:
        genereads[split[4]][1].append(ratio*int(split[9]))

## MANN-WHITNEY U TEST FOR ALL GENES

for i in range(len(genes)):
    Rv = genes[i][0]; gene = genes[i][1]; start = genes[i][2]; end = genes[i][3]
    Lib1Counts = genereads[Rv][0]
    Lib2Counts = genereads[Rv][1]
    TA = len(genereads[Rv][0])
    if TA == 0:
        print "%s\t%s\t%d\t%s" % (Rv,gene,TA,'Gene Has No TAs')
    else:
        if sum(Lib1Counts) == 0 and sum(Lib2Counts) ==0:
            print "%s\t%s\t%d\t%s" % (Rv,gene,TA,'No Insertions in Either Condition')
        else:
            U, p_val = scipy.stats.mannwhitneyu(Lib1Counts,Lib2Counts)
            CountRatio = float(sum(Lib2Counts)+1)/float(sum(Lib1Counts)+1)
            print "%s\t%s\t%d\t%d\t%0.5f\t%0.3f" % (Rv,gene,TA,U,p_val,CountRatio)


        

