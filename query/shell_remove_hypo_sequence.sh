#!/usr/bin/bash

read -p  'Enter your fasta file from remove hypothetical_sequence: ' user_var

#read -p  'Give File_name to extract all id from above file : ' all_id
grep ">" $user_var   | awk '{print $1}' > all_id

#read -p  'Give File_name to extract only hypo_id : ' hypo_id
grep "hypo" $user_var |  awk '{print $1}' > hypo_id

#read -p 'Give output file name for non_hypo ids: ' non_hypo_id
awk 'FNR==NR{ a[$1]; next } !($1 in a)'  hypo_id  all_id  > non_hypo_id

sed -i 's/>//g' non_hypo_id


read -p 'Give output file name for  Non-hypothetical sequences: ' non_hypo_seq
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' non_hypo_id $user_var >  $non_hypo_seq       #Extract sequence from original fasta file

cp $non_hypo_seq query_protein_sequence

#cp query_protein_sequence ../psychrophile/with_....
cp query_protein_sequence ../subject

rm all_id hypo_id non_hypo_id 






















