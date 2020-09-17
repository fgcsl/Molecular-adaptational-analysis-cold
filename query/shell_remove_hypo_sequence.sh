#!/bin/bash

read -p  'Enter your fasta file from remove hypothetical_sequence: ' user_var

if [ -e $user_var ] #file exit or not
then
    if [ -s $user_var ]  #file empty or not
    then
        echo "Thanks for entering a file"
        grep ">" $user_var   | awk '{print $1}' > all_id
        grep "hypo" $user_var |  awk '{print $1}' > hypo_id
        awk 'FNR==NR{ a[$1]; next } !($1 in a)'  hypo_id  all_id  > non_hypo_id
        sed -i 's/>//g' non_hypo_id

        read -p 'Give output file name for  Non-hypothetical sequences : ' non_hypo_seq   #For output file name 
	

        if [ -d ../subject ]
        then
		#Using perl For extracting sequence from your fasta input file in a nonhypo ids
                perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' non_hypo_id $user_var >  $non_hypo_seq
		cp $non_hypo_seq query_protein_sequence
                echo "Your Non-hypothetical sequences under \"query_protein_sequence\" file"
		cp query_protein_sequence ../subject
               # echo "Your Non-hypothetical sequences under \"query_protein_sequence\" file"
		echo "Non-hypothetical sequences file is sucssesfully copy in subject directory for further analysis. Please before proceed for next step change your path to subject directory"
		
		rm all_id hypo_id non_hypo_id
	else 
		echo "Error: you dont have subject directory with your query directory"
		rm  all_id hypo_id non_hypo_id
		fi
        

    else
        echo "This file is Empty. please enter valid fasta file"
    fi
else
        echo "This is not a valid file"
        echo "Sorry, The file you Enter is not exit please check and try again."
fi
