#!/bin/bash
for file in *.txt
do
	  awk '{print $3}' ${file} > ${file}.new
  done

  paste *.txt.new > result
  rm -f *.txt.new


