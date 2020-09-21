ls *.fasta > all_subject_fasta_list
cat *.fasta > subject_protein_sequence

sed 's/.*/makeblastdb -in & -dbtype prot/g' all_subject_fasta_list > script_makedb
sh script_makedb

#read -p  'Enter path of your query file : ' user_var      #user_var is a variable

ls query_protein_sequence > query_file
sed 's/.*/blastp -query & -db/g' query_file > script_blastp1

sed 's/$/ -evalue 1e-15 -best_hit_score_edge 0.05 -best_hit_overhang 0.25 -outfmt 6  -max_target_seqs 1  -out /g' all_subject_fasta_list > script_blastp2


sed 's/.fasta/_blastp_output/g' all_subject_fasta_list > script_blastp3

paste script_blastp2 script_blastp3 > script_blastp4

awk 'FNR==NR {a=$0;next} {print a,$0}'  script_blastp1 script_blastp4 > script_blastp

sh script_blastp


ls *_blastp_output > all_blastp_output_list

sed "s/.*/awk '{print \$1,\$2}' & \| perl -ne 'print if ! \$x{\$_}++' > /g" all_blastp_output_list > script_output_norepeats_1
sed 's/_blastp_output/_blastp_output_norepeats/g' all_blastp_output_list > script_output_norepeats_2

paste script_output_norepeats_1 script_output_norepeats_2 > script_output_norepeats_final
sh script_output_norepeats_final


ls *blastp_output_norepeats > all_blastp_output_norepeats_list

awk 'ORS=" "' all_blastp_output_norepeats_list > all_blastp_output_norepeats_list_row

cat all_blastp_output_norepeats_list |wc |awk '{print $1}'> word_count_output_norepeats_file


#awk '{print "my name is" $1  "i am from fgcsl lab"} filename 

awk '{print "awk {a[$1]=a[$1] \" \"$2;n[$1]++} n[$1]=="$1  "{print $1 a[$1]}"  }' word_count_output_norepeats_file   |sed "s/awk {/awk '{/g" |sed "s/$/'/g" > command_comparing_norepeats_files

paste command_comparing_norepeats_files all_blastp_output_norepeats_list_row > SCRIPT_FINAL_QUERY_MATCH
sh SCRIPT_FINAL_QUERY_MATCH > FINAL_QUERY_MATCH


#csplit FINAL_QUERY_MATCH 
csplit  -k  -f  ps_   FINAL_QUERY_MATCH '/ /' {100000} 
rm ps_00*

echo "please wait it will take a while...."

#extract list of all ps file
ls ps_* | sed 's/_/ /g' | sort -nk 2 |sed 's/ /_/g' > list_ps_all
cp list_ps_all list_ps_col_all 
sed  's/.*/> &_col/g' list_ps_col_all > list_ps_col_all_edit_1							#make output file name of next script add (> &_col) in the starting and end of the list_ps_col_all file

#change Row to coloumn 
cp list_ps_col_all_edit_1  rows_to_coloumn  							#copy file as rows_to_coloumn
sed  "s/^/awk '{for(i=1;i<=NF;i++) printf \"\%s\\\n\",\$i}' /" list_ps_col_all > rows_to_coloumn_edit_1  	#add awk command in front of rows_to_coloumn file to change row into coloumn
paste rows_to_coloumn_edit_1 list_ps_col_all_edit_1 > script_to_change_rows_to_coloumn		#paste both and save in script_to_change_rows_to_coloumn file
sh script_to_change_rows_to_coloumn  							#to run script

#extract query id which is in first (1st row) inside every ps_col ansd save it in ps_no_query 
ls ps_*col |sed 's/_/ /g' | sort -nk 2 |sed 's/ /_/g' > list_ps_col_all			#find list of all ps_*col and arrange it in order 
cp  list_ps_col_all list_ps_col_all_dup
sed 's/_col/_query/g' list_ps_col_all_dup > list_ps_query_all
sed  's/.*/head -1 & > /g' list_ps_col_all_dup > list_ps_col_all_dup_edit_1
paste list_ps_col_all_dup_edit_1 list_ps_query_all > script_headline_query_all
sh script_headline_query_all

sed -i '1d' ps_*_col									#remove first line(row) from all ps_*col using -i itself

cp list_ps_col_all list_ps_col_all_dup1

sed "s/.*/perl -ne 'if(\/^>(\\\S+)\/){\$c=\$i{\$1}}\$c?print:chomp;\$i\{\$_}=1 if @ARGV' & subject_protein_sequence > /g" list_ps_col_all_dup1 > extract_script_col_sequence_all

sed 's/$/_sequence/g' list_ps_col_all_dup1 > list_ps_col_sequence_all
paste extract_script_col_sequence_all list_ps_col_sequence_all > script_col_sequence_all
sh script_col_sequence_all

ls ps_*query |sed 's/_/ /g' | sort -nk 2 |sed 's/ /_/g' > list_ps_query_all			#list of ps_*query files and arrange it in order

sed "s/.*/perl -ne 'if(\/^>(\\\S+)\/){\$c=\$i{\$1}}\$c?print:chomp;\$i\{\$_}=1 if @ARGV' & query_protein_sequence > /g" list_ps_query_all > extract_script_query_sequence_all

sed 's/$/_sequence/g' list_ps_query_all > list_ps_query_sequence_all
paste  extract_script_query_sequence_all list_ps_query_sequence_all > script_query_sequence_all
sh script_query_sequence_all

rm ps*col		#delete all col id's after extracting sequence
rm ps*query		#delete all query id after extracting query sequence
sed 's/^/rm /g' list_ps_all |sh  #remove csplit file  
#/usr/bin/bash
mkdir  subject_seq

#make directory  inside subject  
ls ps*_col_sequence | sed 's/_/ /g' | sort -nk 2 |sed 's/ /_/g' > script_mkdir_in_subject
sed  's/_col_sequence//g' script_mkdir_in_subject > script_mkdir_in_subject_edit_1
sed  's/^/mkdir subject_seq\//g' script_mkdir_in_subject_edit_1 > script_mkdir_in_subject_edit_2
sh script_mkdir_in_subject_edit_2

#copy all ps_col_sequence to directory ps that is inside subject directories
awk '{print $2}' script_mkdir_in_subject_edit_2 > script_copy_col_sequence_path
ls ps*_col_sequence | sed 's/_/ /g' | sort -nk 2 |sed 's/ /_/g' > script_copy_col_sequence_mv
sed  's/^/mv /g' script_copy_col_sequence_mv > script_copy_col_sequence_mv_edit_1

paste script_copy_col_sequence_mv_edit_1 script_copy_col_sequence_path  > script_copy_col_sequence
sh script_copy_col_sequence
rm  script_copy_col_sequence_path script_copy_col_sequence_mv_edit_1

rm *phr *pin *psq                               # remove all database no more in use  				
#now we have to calculate frequency of protein sequence of query and subject independently
ls ps*query_sequence  | sed 's/_/ /g' | sort -nk 2 |sed 's/ /_/g' > extract_all_indi
cp extract_all_indi list_output_all_indi
sed  's/_query_sequence/_all_indi/g' list_output_all_indi > list_output_all_indi_edit_1

sed  's/.*/perl calculation_perl_program_frquency_12.pl & >/g' extract_all_indi > extract_all_indi_edit_1
paste extract_all_indi_edit_1 list_output_all_indi_edit_1 > script_extract_all_indi
sh script_extract_all_indi 

#csplit script_extract_all_indi
awk '{print $5}' script_extract_all_indi > list_all_indi_all
sed  "s/$/ '\/\/' {10000}/g" list_all_indi_all > list_all_indi_all_edit_1
ls ps*query_sequence  | sed 's/_/ /g' | sort -nk 2 |sed 's/ /_/g' > list_query_sequence_all
sed  's/_query_sequence/_indicator_query_ /g' list_query_sequence_all  > list_query_sequence_all_edit_1
sed  's/^/csplit   -k  -f /g' list_query_sequence_all_edit_1 > list_query_sequence_all_edit_2
paste list_query_sequence_all_edit_2 list_all_indi_all_edit_1 > script_csplit_all_indicator
sh script_csplit_all_indicator

sed -i 's/.*/t.test \(a,mu=&\)/g' ps_*_indicator_query*


rm *_00
awk '{print $5}' script_extract_all_indi > list_indicator_query_all 
sed 's/_all_indi/_indicator_query_*/g' list_indicator_query_all > list_indicator_query_all_edit_1
sed 's/^/mv /g' list_indicator_query_all_edit_1 > list_indicator_query_all_edit_2

ls ps*_all_indi  | sed 's/_/ /g' | sort -nk 2 |sed 's/ /_/g' > list_ps_cp_dir
sed  's/_all_indi//g' list_ps_cp_dir > list_ps_cp_dir_edit_1
sed  's/^/subject_seq\//g' list_ps_cp_dir_edit_1 > list_ps_cp_dir_edit_2

paste list_indicator_query_all_edit_2 list_ps_cp_dir_edit_2 > script_copy_all_indicator_to_all_subject_ps
sh script_copy_all_indicator_to_all_subject_ps

rm ps*
#copy ps folder of subject_seq directory in outside the directory

#for i in subject/*; do  if [ -d $i ]; then  echo mv $i ../; fi; done  | sed 's/_/ /g' | sort -nk 3 | sed 's/ps /ps_/g' |sh

pwd > mv_pwd_command
sed  's/^/mv subject_seq\/ps* /g' mv_pwd_command > move_ps_outside
sh move_ps_outside
rm -r subject_seq		#remove subject_seq directory

#remove extra files whivh are not in use any more
#rm *blastp_output_norepeats *blastp_output *.fasta

for i in ps_*/; do echo $i; done | sed 's/_/ /g' | sort -nk 2 | sed 's/ /_/g' | sed 's/.*/csplit  -k  -f  &split_/g' > csplit_subject_seq_ps_1
for i in ps_*/ps_*_col_sequence; do echo $i; done | sed 's/_/ /g' | sort -nk 2,4 | sed 's/ /_/g' | sed "s/$/ '\/ \/' {100000} /g" > csplit_subject_seq_ps_2
paste csplit_subject_seq_ps_1 csplit_subject_seq_ps_2 |sh

echo "please wait t will take a while...."

for i  in ps_*/split*; do echo $i; done|sed "s/_/ /g" | sort -nk 2 | sed "s/ /_/g" | sed 's/.*/perl calculation_perl_program_frquency_12.pl & > /g' > script_calculation1
for i  in ps_*/split*; do echo $i; done|sed "s/_/ /g" | sort -nk 2 | sed "s/ /_/g"  | sed 's/$/_all_indi/g' > script_calculation2
paste script_calculation1 script_calculation2 |sh

echo "please wait it will take a while...."

for i in ps*/split_*_all_indi; do echo $i; done | sed 's/_/ /g' | sort -nk 2 | sed 's/ /_/g' | sed 's/.*/csplit  -k  -f &_/g'  > indicator_csplit_script_1
for i in ps*/split_*_all_indi; do echo $i; done | sed 's/_/ /g' | sort -nk 2 | sed 's/ /_/g' | sed "s/$/ '\/\/' {100000}/g" > indicator_csplit_script_2
paste indicator_csplit_script_1 indicator_csplit_script_2 |sh

rm ps*/split_*_all_indi_00

echo "please wait it will take a while...."

#Collect all frequency of  indicators from ps directories save in ALL_1ST_INDICATORS ALL_2ND_INDICATORS ALL_3RD_INDICATORS......... ALL_12TH_INDICATORS

for i in ps_*/split_*_all_indi_01; do echo $i; done | sed "s/_/ /g"  | sort -nk 2 | sed "s/ /_/g" | sed 's/$/ >>/g' |sed 's/split_01_all_indi_01 >>/split_01_all_indi_01 >/g' | sed 's/^/cat /g' > join_01_all_indi_01
for i in ps_*/split_*_all_indi_01; do echo $i; done | sed "s/_/ /g"  | sort -nk 2 | sed "s/ /_/g"  | sed 's/split_[0-9]*//g' | sed 's/_all_indi_01//g' | sed 's/$/ALL_1_INDICATORS/g' > join_02_all_indi_01
paste join_01_all_indi_01 join_02_all_indi_01 > script_ALL_1ST_INDICATORS
sh script_ALL_1ST_INDICATORS

sed -i -e 's/_indi_01/_indi_02/g ; s/1_INDICATORS/2_INDICATORS/g' script_ALL_1ST_INDICATORS 
sh script_ALL_1ST_INDICATORS

sed -i -e 's/_indi_02/_indi_03/g ; s/2_INDICATORS/3_INDICATORS/g' script_ALL_1ST_INDICATORS
sh script_ALL_1ST_INDICATORS

sed -i -e 's/_indi_03/_indi_04/g ; s/3_INDICATORS/4_INDICATORS/g' script_ALL_1ST_INDICATORS
sh script_ALL_1ST_INDICATORS

sed -i -e 's/_indi_04/_indi_05/g ; s/4_INDICATORS/5_INDICATORS/g' script_ALL_1ST_INDICATORS
sh script_ALL_1ST_INDICATORS

sed -i -e 's/_indi_05/_indi_06/g ; s/5_INDICATORS/6_INDICATORS/g' script_ALL_1ST_INDICATORS
sh script_ALL_1ST_INDICATORS

sed -i -e 's/_indi_06/_indi_07/g ; s/6_INDICATORS/7_INDICATORS/g' script_ALL_1ST_INDICATORS
sh script_ALL_1ST_INDICATORS

#sed -i -e 's/_indi_07/_indi_08/g ; s/7_INDICATORS/8_INDICATORS/g' script_ALL_1ST_INDICATORS
#sh script_ALL_1ST_INDICATORS

#sed -i -e 's/_indi_08/_indi_09/g ; s/8_INDICATORS/9_INDICATORS/g' script_ALL_1ST_INDICATORS
#sh script_ALL_1ST_INDICATORS

#sed -i -e 's/_indi_09/_indi_10/g ; s/9_INDICATORS/10_INDICATORS/g' script_ALL_1ST_INDICATORS
#sh script_ALL_1ST_INDICATORS


#sed -i -e 's/_indi_10/_indi_11/g ; s/10_INDICATORS/11_INDICATORS/g' script_ALL_1ST_INDICATORS
#sh script_ALL_1ST_INDICATORS

#sed -i -e 's/_indi_11/_indi_12/g ; s/11_INDICATORS/12_INDICATORS/g' script_ALL_1ST_INDICATORS
#sh script_ALL_1ST_INDICATORS

##################################################################################################################################################
###################################  Prepairing scripts for One-Sample Student t-test ###########################################################

#row to col add ac =() for t.test

for i in ps_*/ALL*; do echo $i; done | sed 's/_/ /g'  | sort -nk 2 | sed 's/ /_/g' | sed "s/.*/awk -vs1= '\{S=S?S OFS s1 \$0 s1:s1 \$0 s1\} END\{print S\}' OFS=, & | sed 's\/.*\/a=c\(\&\)\/g' > /g" > script_col_to_row_add_ac_1
for i in ps_*/ALL*; do echo $i; done | sed 's/_/ /g'  | sort -nk 2 | sed 's/ /_/g' | sed 's/$/_ac/g' > script_col_to_row_add_ac_2
paste script_col_to_row_add_ac_1 script_col_to_row_add_ac_2 |sh 

# delete directory which don't have a query indicators files inside ps directory's  because of illigal divisible by 0 error. so no need to campare 
for i in ps_*/ALL*; do echo $i; done  | sed 's/\// /g' | awk '{print $1}' > ll1
for i in ps_*/ps_*_indicator_query_*; do echo $i; done | sed 's/\// /g' | awk '{print $1}' > ll2
grep -Fxvf  ll2 ll1 > ll3		#remove different (unique) value from two file i.e the file which dont have query seq files
awk '!a[$1]++' ll3 > remove_sub_directory    #delete repeate value and print only once not in use there is no query indicators inside these directories
sed  's/^/rm -r /g' remove_sub_directory > remove_sub_directory_edit_1
sh remove_sub_directory_edit_1



#cat ALL*ac and  ps_*_indicator_query_* 
for i in ps_*/ALL*ac; do echo $i; done | sed 's/_/ /g'  | sort -nk 3 | sed 's/ /_/g' > lol1
for i in ps_*/ps_*_indicator_query_*; do echo $i; done | sed "s/_/ /g"  | sort -nk 6 | sed "s/ /_/g"  >lol2
paste lol1 lol2 | sed 's/.*/cat & >/g' > lol3

for i in ps_*/ps_*_indicator_query_*; do echo $i; done | sed "s/_/ /g"  | sort -nk 6 | sed "s/ /_/g" | sed 's/ps_[0-9]*_indicator_query/T_TEST_COMPLETE_INDICATOR/g' > t_test_output

paste lol3 t_test_output > script_T_TEST_COMPLETE_INDICATOR
sh script_T_TEST_COMPLETE_INDICATOR


 #################################################################################################################################################
############################################# Prepairing script to finding  p-value should be less than 0.05 #####################################


for i in ps_*/T_TEST_COMPLETE_INDICATOR*; do echo $i; done | sed "s/_/ /g" | sort -nk 2 | sed "s/ /_/g" | sed "s/.*/Rscript & \| grep \"p-value\" \| awk '\{if \(\$9 <0.05\) print \$0\}' >/g" > make_rscript1
for i in ps_*/T_TEST_COMPLETE_INDICATOR*; do echo $i; done | sed "s/_/ /g" | sort -nk 2 | sed "s/ /_/g" | sed 's/T_TEST_COMPLETE_INDICATOR_/Rscript_result_indicator_/g' > make_rscript2
echo "please wait for result it will take some time"
paste make_rscript1 make_rscript2 > script_Rscript_result_indicator
sh script_Rscript_result_indicator



#Name of the 12 indicators manage according to our calculation_perl_program_frquency_12.pl (program file)

echo "1. Acidic
2.  Proline
3.  Aliphatic
4.  Aromatic
5.  Argine_to_Lysine
6.  Tyrosine
7.  Tryptophan" > 12_indicators_name

 #################################################################################################################################################
 ############################## On the bases of direction of change Calculating Cold hot Ratio ################################################

ls -lrth ps_*/Rscript_result_indicator_* | awk '{if ($5>0) print $9}' > Rscript_directories
ls -lrth ps_*/Rscript_result_indicator_* | awk '{if ($5>0) print $9}' | sed 's/^/cat /g' |sh > Rscript_directories_result

paste Rscript_directories Rscript_directories_result | awk '{if ($4>0) print $0}'  > Rscript_directories_result_together_positive #direction of change cold (t = +ve)
paste Rscript_directories Rscript_directories_result | awk '{if ($4<0) print $0}'  > Rscript_directories_result_together_negative #direction of change hot (t = -ve)

grep "Rscript_result_indicator_01" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_1
grep "Rscript_result_indicator_01" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_1
cat LIST_OF_POSITIVE_INDICATORS_1 |wc > cold
cat LIST_OF_NEGATIVE_INDICATORS_1 |wc > hot
paste cold hot > COLD_HOT_RATIO

grep "Rscript_result_indicator_02" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_2
grep "Rscript_result_indicator_02" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_2
cat LIST_OF_POSITIVE_INDICATORS_2 |wc >> cold
cat LIST_OF_NEGATIVE_INDICATORS_2 |wc >> hot
paste cold hot > COLD_HOT_RATIO

grep "Rscript_result_indicator_03" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_3
grep "Rscript_result_indicator_03" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_3
cat LIST_OF_POSITIVE_INDICATORS_3 |wc >> cold
cat LIST_OF_NEGATIVE_INDICATORS_3 |wc >> hot
paste cold hot > COLD_HOT_RATIO

grep "Rscript_result_indicator_04" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_4
grep "Rscript_result_indicator_04" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_4
cat LIST_OF_POSITIVE_INDICATORS_4 |wc >> cold
cat LIST_OF_NEGATIVE_INDICATORS_4 |wc >> hot
paste cold hot > COLD_HOT_RATIO

grep "Rscript_result_indicator_05" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_5
grep "Rscript_result_indicator_05" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_5
cat LIST_OF_POSITIVE_INDICATORS_5 |wc >> cold
cat LIST_OF_NEGATIVE_INDICATORS_5 |wc >> hot
paste cold hot > COLD_HOT_RATIO

grep "Rscript_result_indicator_06" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_6
grep "Rscript_result_indicator_06" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_6
cat LIST_OF_POSITIVE_INDICATORS_6 |wc >> cold
cat LIST_OF_NEGATIVE_INDICATORS_6 |wc >> hot
paste cold hot > COLD_HOT_RATIO

grep "Rscript_result_indicator_07" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_7
grep "Rscript_result_indicator_07" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_7
cat LIST_OF_POSITIVE_INDICATORS_7 |wc >> cold
cat LIST_OF_NEGATIVE_INDICATORS_7 |wc >> hot
paste cold hot > COLD_HOT_RATIO

#grep "Rscript_result_indicator_08" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_8
#grep "Rscript_result_indicator_08" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_8
#cat LIST_OF_POSITIVE_INDICATORS_8 |wc >> cold
#cat LIST_OF_NEGATIVE_INDICATORS_8 |wc >> hot
#paste cold hot > COLD_HOT_RATIO

#grep "Rscript_result_indicator_09" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_9
#grep "Rscript_result_indicator_09" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_9
#cat LIST_OF_POSITIVE_INDICATORS_9 |wc >> cold
#cat LIST_OF_NEGATIVE_INDICATORS_9 |wc >> hot
#paste cold hot > COLD_HOT_RATIO

#grep "Rscript_result_indicator_10" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_10
#grep "Rscript_result_indicator_10" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_10
#cat LIST_OF_POSITIVE_INDICATORS_10 |wc >> cold
#cat LIST_OF_NEGATIVE_INDICATORS_10 |wc >> hot
#paste cold hot > COLD_HOT_RATIO

#grep "Rscript_result_indicator_11" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_11
#grep "Rscript_result_indicator_11" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_11
#cat LIST_OF_POSITIVE_INDICATORS_11 |wc >> cold
#cat LIST_OF_NEGATIVE_INDICATORS_11 |wc >> hot
#paste cold hot > COLD_HOT_RATIO

#grep "Rscript_result_indicator_12" Rscript_directories_result_together_positive > LIST_OF_POSITIVE_INDICATORS_12
#grep "Rscript_result_indicator_12" Rscript_directories_result_together_negative > LIST_OF_NEGATIVE_INDICATORS_12
#cat LIST_OF_POSITIVE_INDICATORS_12 |wc >> cold
#cat LIST_OF_NEGATIVE_INDICATORS_12 |wc >> hot
#paste cold hot > COLD_HOT_RATIO


awk '{print $1,$4}' COLD_HOT_RATIO > COLD_HOT_RATIO_species_name
paste 12_indicators_name COLD_HOT_RATIO_species_name  | column -t > COLD_HOT_RATIO_name

#for i in LIST_OF_*_INDICATORS_*; do echo $i; done| sed 's/_/ /g' | sort -nk 5 | sed 's/ /_/g' | sed "s/.*/sed \"s\/\\\\\/\/ \/g\" & | awk '\{print \$1\}' | sed \"s\/$\/_T\/g\"  > /g" > LIST_OF_POSI_NEGA_INDICATORS_true1

for i in LIST_OF_*_INDICATORS_*; do echo $i; done| sed 's/_/ /g' | sort -nk 5 | sed 's/ /_/g' | sed "s/.*/sed \"s\/\\\\\/\/ \/g\" & | awk '\{print \$1\}' > /g" > script_POSI_NEGA_TRUE1



for i in LIST_OF_*_INDICATORS_*; do echo $i; done| sed 's/_/ /g' | sort -nk 5 | sed 's/ /_/g' | sed 's/LIST_OF/TRUE/g' > script_POSI_NEGA_TRUE2
paste script_POSI_NEGA_TRUE1 script_POSI_NEGA_TRUE2 |sh


for i in ps_*; do echo $i; done | sed 's/_/ /g' | sort -nk 2 | sed 's/ /_/g' > ALL_ps_LIST

#for i in TRUE*_INDICATORS_[0-9]*; do echo $i; done | sed "s/_/ /g" | sort -nk 4 | sed "s/ /_/g" | sed "s/.*/grep -Fxvf & ALL_ps_LIST | sed 's\/\$\/_F\/g' > /g" > script_making_mistatch_sore1

for i in TRUE*_INDICATORS_[0-9]*; do echo $i; done | sed "s/_/ /g" | sort -nk 4 | sed "s/ /_/g" | sed "s/.*/grep -Fxvf & ALL_ps_LIST  > /g" > script_making_mistatch_sore1

for i in TRUE*_INDICATORS_[0-9]*; do echo $i; done | sed "s/_/ /g" | sort -nk 4 | sed "s/ /_/g" | sed 's/TRUE/FALSE/g' > script_making_mistatch_sore2

paste script_making_mistatch_sore1 script_making_mistatch_sore2 |sh



sed -i 's/$/ 0/g' FALSE_*INDICATORS_*
sed -i 's/$/ 1/g' TRUE_*INDICATORS_*



for i in TRUE_*_INDICATORS_*; do echo $i; done | sed 's/_/ /g' | sort -nk 4 | sed 's/ /_/g' | sed 's/^/cat /g'> ALL_TRUE_INDICATORS
for i in FALSE_*_INDICATORS_*; do echo $i; done | sed 's/_/ /g' | sort -nk 4 | sed 's/ /_/g' | sed 's/$/ >/g'> ALL_FALSE_INDICATORS
paste ALL_TRUE_INDICATORS ALL_FALSE_INDICATORS > ALL_TRUE_FALSE_INDICATORS
for i in FALSE_*_INDICATORS_*; do echo $i; done | sed 's/_/ /g' | sort -nk 4 | sed 's/ /_/g' | sed 's/^/TRUE_/g' > list_TRUE_FALSE_INDICATORS
paste ALL_TRUE_FALSE_INDICATORS list_TRUE_FALSE_INDICATORS |sh



for i in TRUE_FALSE_*INDICATORS*; do echo $i; done | sed 's/_/ /g' | sort -nk 5 | sed 's/ /_/g' | sed "s/.*/ sed 's\/_\/ \/g' & | sort -nk 2 | sed 's\/ \/_\/' | sed 's\/ps_\[0-9\]*\/\/g' | sed 's\/0\/-\/g' | sed 's\/1\/+\/g'  > /g" >  script_scrore1
awk '{print $4}' script_scrore1 | sed 's/TRUE_FALSE/FINAL/g' > script_scrore2
paste script_scrore1 script_scrore2 |sh


paste FINAL_POSITIVE_INDICATORS_1 FINAL_POSITIVE_INDICATORS_2 FINAL_POSITIVE_INDICATORS_3 FINAL_POSITIVE_INDICATORS_4 FINAL_POSITIVE_INDICATORS_5 FINAL_POSITIVE_INDICATORS_6 FINAL_POSITIVE_INDICATORS_7 > SCORE_COLD
#CHANGE + and - sign to calculate total no of +ive score in each protein
sed -i "s/+/1/g ; s/-/0/g" SCORE_COLD
awk '{for(i=1; i<=NF; i++) t+=$i; print t; t=0}' SCORE_COLD > positive_count
sed -i "s/1/+/g ; s/0/-/g" SCORE_COLD
paste  ALL_ps_LIST SCORE_COLD  positive_count > COLD_ADAPTATION_SCORE





#QUERY GRAVY

#for extractig gene ids of query sequence  which are matched with subject to find the cold adaptation protein (which make cold)


awk '{print $1}' FINAL_QUERY_MATCH | sed "s/>//g"  > query_matched_ids
awk '{print $1}' FINAL_QUERY_MATCH | sed "s/^/grep \"/ g" | sed "s/$/\" query_protein_sequence  /g"   |sh  | awk '{print "ps_"NR " " $0}' >  query_matched_list_with_protein_names_id



#Scripting for Query Gravy Calculation 

#extract all match sequence from query_protein_sequence file 
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' query_matched_ids query_protein_sequence > query_matched_sequence  #in query_matched_ids file we have all matched id's


#split all query_sequnce protein to calculate gravy of each protein 
csplit -k -f ps_query_sequence_ query_matched_sequence  '/ /' {100000}

#rm  ps_query_sequence_00 because it is empty
rm ps_query_sequence_00


#make python_files for gravy calculation 

echo -e '#!/usr/bin/env python\nfrom Bio.SeqUtils.ProtParam import ProteinAnalysis' > python_top

echo -e '\nanalysed_seq = ProteinAnalysis(my_seq)\nprint analysed_seq.gravy()' > python_bottom


#all ps_query_sequence list in sort form 
for i in ps_query_sequence*; do echo $i; done | sed "s/_/ /g" | sort -nk 4 | sed "s/ /_/g" > list_ps_query_sequence

#make all ps_query_sequence as a middle python for that we have to create python varible for each query_seq files . for that: we need to remove  first line and add my_sql= (variable) and at the starting and end with doublecote ("")
sed "s/.*/sed \"1d\" & |  awk '\{printf\(\"%s\"\,\$0\)}' |  sed \'s\/.*\/my_seq=\"\&\"\/g\' > /g" list_ps_query_sequence > script_variable_1

sed  "s/query_sequence/query_python_var/g" list_ps_query_sequence > script_variable_2
paste script_variable_1 script_variable_2 > script_python_middle
sh script_python_middle

#python cat python_top ps_query_sequence_python_var_* python_bottom |python2 #script
echo  "Gravy caclulation for query sequence...."


for i in ps_query_python_var_*; do echo $i; done | sed "s/_/ /g" |sort -nk 5 | sed "s/ /_/g" > list_ps_query_sequence_python_var
sed "s/.*/cat python_top & python_bottom \|python2 \| sed 's\/.*\/t.test\(a,mu= \&\)\/g' >/g" list_ps_query_sequence_python_var > script_python_cat_1

sed "s/query_sequence_//g" list_ps_query_sequence >ps_list


sed 's/query_python_var/indicator_query_gravy/g' list_ps_query_sequence_python_var > list_indicator_query_gravy
paste ps_list list_indicator_query_gravy | sed 's/[[:space:]]/\//g' > script_python_cat_2
paste script_python_cat_1 script_python_cat_2 > script_query_amu
sh script_query_amu 




#scripting for subject Gravy calculation
echo "Deleting splits files.."

for i in ps_*/split_*all_indi; do echo $i; done | sed "s/^/rm /g" |sh
for i in ps_*/split_*all_indi*; do echo $i; done | sed "s/^/rm /g" |sh
for i in ps_*/split_00; do echo $i; done | sed "s/^/rm /g" |sh

#awk '{print $3}'  script_calculation1 > list_split_combine_ps
echo "Gravy Calculation is process... it will take a while."
for i in ps_*/split*; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g" > list_split_combine_ps

for i in ps_*/split*; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g" |sed 's/split/py_gravy/g' > list_split_combine_ps_output

sed "s/.*/sed \"1d\" & |  awk '\{printf\(\"%s\"\,\$0\)}' |  sed \'s\/.*\/my_seq=\"\&\"\/g\' > /g" list_split_combine_ps > script_making_variable_split_files

paste script_making_variable_split_files list_split_combine_ps_output > script_python_variable_for_all_ps_split
sh script_python_variable_for_all_ps_split


for i in ps_*/py_gravy_*; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g"  | sed "s/.*/cat python_top & python_bottom \|python2 >>/" | sed "s/py_gravy_01 python_bottom |python2 >>/py_gravy_01 python_bottom \|python2 >/g" > script_cat_all_python_1

for i in ps_*/py_gravy_*; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g" | sed 's/py_gravy_[0-9][0-9]/ALL_gravy_INDICATORS/g' > script_cat_all_python_2

paste script_cat_all_python_1 script_cat_all_python_2 > script_cat_all_python_tmb #tmp python_top middle(py_gravy_ variables) bottom 

sh script_cat_all_python_tmb



#change ALL_gravy_INDICATORS inside ps_directory to row and add at the starting position  a=c "(",,,,     and last ")"  to t-test 
for i in ps_*/ALL_gravy_INDICATORS; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g" | sed "s/.*/awk -vs1= '{S=S?S OFS s1 \$0 s1:s1 \$0 s1} END{print S}' OFS=, & | sed 's\/.*\/a=c \\\(\&\\\)\/g' >  /g" > script_col_to_row_add_ac_for_gravy

for i in ps_*/ALL_gravy_INDICATORS; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g" | sed 's/$/_ac/g' > script_col_to_row_add_ac_for_gravy_output_list

paste script_col_to_row_add_ac_for_gravy script_col_to_row_add_ac_for_gravy_output_list > script_add_ac_gravy_final
sh script_add_ac_gravy_final


#for T-test final files

for i in ps_*/ALL_gravy_INDICATORS_ac; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g" | sed 's/^/cat /g' >T-test_1
for i in ps_*/ps_indicator_query_gravy_*; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g" | sed 's/$/ > /g' > T-test_2

for i in ps_*/ALL_gravy_INDICATORS_ac; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g" | sed 's/ALL_gravy_INDICATORS_ac/T_TEST_COMPLETE_INDICATOR_GRAVY/g' > T-test_3_output
paste T-test_1 T-test_2 T-test_3_output > script_t_test_complete_gravy
sh script_t_test_complete_gravy

#Rscript 
for i in ps_*/T_TEST_COMPLETE_INDICATOR_GRAVY; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g"  | sed "s/.*/Rscript & \| grep \"p-value\" \| awk \'FS=\",\"  \{if \(\$9<=0.05\) print \$0\}\'  >  /g" > script_Rscript1
for i in ps_*/T_TEST_COMPLETE_INDICATOR_GRAVY; do echo $i; done | sed "s/_/ /g" |sort -nk 2 | sed "s/ /_/g" | sed 's/T_TEST_COMPLETE_INDICATOR_GRAVY/Rscript_result_indicator_gravy/g' > script_Rscript2
paste script_Rscript1 script_Rscript2 > script_Rscript_final_gravy
sh script_Rscript_final_gravy

#calculation cold hot ratio of gravy
echo "Last step calculating cold hot ratio..."

ls -lrth ps_*/Rscript_result_indicator_gravy | awk '{if ($5>0) print $9}' >  Rscript_directories_gravy
ls -lrth ps_*/Rscript_result_indicator_gravy | awk '{if ($5>0) print $9}'| sed 's/^/cat /g' |sh > Rscript_directories_gravy_result
paste Rscript_directories_gravy Rscript_directories_gravy_result  | awk '{if ($4>0) print $0}' > LIST_OF_POSITIVE_GRAVY
paste Rscript_directories_gravy Rscript_directories_gravy_result  | awk '{if ($4<0) print $0}' >LIST_OF_NEGATIVE_GRAVY

cat LIST_OF_POSITIVE_GRAVY |wc > cold_gravy
cat LIST_OF_NEGATIVE_GRAVY |wc > hot_gravy
paste cold_gravy hot_gravy > GRAVY_ratio
awk '{print $1,$4}' GRAVY_ratio  > COLD_HOT_RATIO_GRAVY
sed -i "s/^/# GRAVY\t/g" COLD_HOT_RATIO_GRAVY
cat COLD_HOT_RATIO_name COLD_HOT_RATIO_GRAVY > COLD_AND_HOT_RATIO_WITH_GRAVY

#score_calculation

for i in LIST_OF_*GRAVY; do echo $i; done | sed 's/_/ /g' | sort -nk 5 | sed 's/ /_/g' | sed "s/.*/sed \"s\/\\\\\/\/ \/g\" & | awk '\{print \$1\}' > /g" >  script_POSI_NEGA_TRUE1_GRAVY
for i in LIST_OF_*GRAVY; do echo $i; done| sed 's/_/ /g' | sort -nk 5 | sed 's/ /_/g' | sed 's/LIST_OF/TRUE/g' > script_POSI_NEGA_TRUE2_GRAVY
paste script_POSI_NEGA_TRUE1_GRAVY script_POSI_NEGA_TRUE2_GRAVY |sh 

for i in TRUE*_GRAVY; do echo $i; done | sed "s/_/ /g" | sort -nk 4 | sed "s/ /_/g" | sed "s/.*/grep -Fxvf & ALL_ps_LIST  > /g" >  script_making_mistatch_sore1_gravy
for i in TRUE*_GRAVY; do echo $i; done | sed "s/_/ /g" | sort -nk 4 | sed "s/ /_/g" | sed 's/TRUE/FALSE/g' > script_making_mistatch_sore2_gravy
paste script_making_mistatch_sore1_gravy script_making_mistatch_sore2_gravy |sh  

sed -i 's/$/ 1/g' TRUE_*GRAVY
sed -i 's/$/ 0/g' FALSE_*GRAVY

for i in TRUE_*GRAVY; do echo $i; done | sed 's/_/ /g' | sort -nk 4 | sed 's/ /_/g' | sed 's/^/cat /g'> ALL_TRUE_GRAVY
for i in FALSE_*GRAVY; do echo $i;  done | sed 's/_/ /g' | sort -nk 4 | sed 's/ /_/g' | sed 's/$/ >/g' > ALL_FALSE_GRAVY
paste ALL_TRUE_GRAVY ALL_FALSE_GRAVY > ALL_TRUE_FALSE_GRAVY
for i in FALSE_*GRAVY; do echo $i; done | sed 's/_/ /g' | sort -nk 4 | sed 's/ /_/g' | sed 's/^/TRUE_/g' > list_TRUE_FALSE_GRAVY
paste ALL_TRUE_FALSE_GRAVY list_TRUE_FALSE_GRAVY |sh



for i in TRUE_FALSE_*GRAVY; do echo $i; done | sed 's/_/ /g' | sort -nk 5 | sed 's/ /_/g' | sed "s/.*/ sed 's\/_\/ \/g' & | sort -nk 2 | sed 's\/ \/_\/' | sed 's\/ps_\[0-9\]*\/\/g' | sed 's\/0\/-\/g' | sed 's\/1\/+\/g'  > /g" > script_gravy_scrore1
awk '{print $4}' script_gravy_scrore1 | sed 's/TRUE_FALSE/FINAL/g' > script_gravy_scrore2

paste script_gravy_scrore1 script_gravy_scrore2 |sh

#FOR COLD_SCORE

paste FINAL_POSITIVE_INDICATORS_1 FINAL_POSITIVE_INDICATORS_2 FINAL_POSITIVE_INDICATORS_3 FINAL_POSITIVE_INDICATORS_4 FINAL_POSITIVE_INDICATORS_5 FINAL_POSITIVE_INDICATORS_6 FINAL_POSITIVE_INDICATORS_7 FINAL_POSITIVE_GRAVY > SCORE_COLD_all_8


paste ALL_ps_LIST SCORE_COLD_all_8 > COLD_ADAPTATION_SCORE_all_8


#awk '{print $1"\t",$2"\t",$3"\t",$4"\t",$5"\t",$NF}' SCORE_COLD_all_8 | sed "s/+/1/g; s/-/0/g" > COLD_FINAL_SIX_INDICATORS

#awk '{for(i=1; i<=NF; i++) t+=$i; print t; t=0}' COLD_FINAL_SIX_INDICATORS > positive_count_2

#sed "s/1/+/g; s/0/-/g" COLD_FINAL_SIX_INDICATORS > COLD_FINAL_SIX_INDICATORS_sign
#paste ALL_ps_LIST COLD_FINAL_SIX_INDICATORS_sign  > COLD_FINAL_SIX_INDICATORS_SIGN

#paste COLD_FINAL_SIX_INDICATORS_SIGN positive_count_2 |sed  '1 i\Protien\tAcidic\tProline\tAliphatic\tAromatic\tArg_to_lys\tGravy\ttotal_count' | awk '{if ($8>=3) print $0}' | column -t > COLD_FINAL_SIX_INDICATORS_SCORE

#Neutral COLD SCORE
#paste COLD_FINAL_SIX_INDICATORS_SIGN positive_count_2 | awk '{if ($8<3) print $0}'  | sed  '1 i\Protien\tAcidic\tProline\tAliphatic\tAromatic\tArg_to_lys\tGravy\ttotal_count' | column -t > Neutral_COLD_SCORE



#FOR HOT SCORE

paste FINAL_NEGATIVE_INDICATORS_1 FINAL_NEGATIVE_INDICATORS_2 FINAL_NEGATIVE_INDICATORS_3 FINAL_NEGATIVE_INDICATORS_4 FINAL_NEGATIVE_INDICATORS_5 FINAL_NEGATIVE_INDICATORS_6 FINAL_NEGATIVE_INDICATORS_7 FINAL_NEGATIVE_GRAVY > SCORE_HOT_all_8

paste ALL_ps_LIST SCORE_HOT_all_8 > HOT_ADAPTATION_SCORE_all_8

#awk '{print $1"\t",$2"\t",$3"\t",$4"\t",$5"\t",$NF}' SCORE_HOT_all_8 | sed "s/+/1/g; s/-/0/g" > HOT_FINAL_SIX_INDICATORS
#awk '{for(i=1; i<=NF; i++) t+=$i; print t; t=0}' HOT_FINAL_SIX_INDICATORS | sed 's/^/-/g'> positive_count_for_hot

#sed "s/1/+/g; s/0/-/g" HOT_FINAL_SIX_INDICATORS > HOT_FINAL_SIX_INDICATORS_sign
#paste ALL_ps_LIST HOT_FINAL_SIX_INDICATORS_sign > HOT_FINAL_SIX_INDICATORS_SIGN

#paste HOT_FINAL_SIX_INDICATORS_SIGN positive_count_for_hot  | awk '{if ($8<=-3) print $0}' | sed  "1 i\Protien\tAcidic\tProline\tAliphatic\tAromatic\tArg_to_lys\tGravy\ttotal_count" | column -t > HOT_FINAL_SIX_INDICATORS_SCORE

#Neutral HOT SCORE
#paste HOT_FINAL_SIX_INDICATORS_SIGN positive_count_for_hot  | awk '{if ($8>-3) print $0}' | sed  "1 i\Protien\tAcidic\tProline\tAliphatic\tAromatic\tArg_to_lys\tGravy\ttotal_count" | column -t > Neutral_HOT_SCORE

#cold protein for each indices
 awk '{print $1,$2}' COLD_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/1/g" >  cold_acidic_prot
 awk '{print $1,$3}' COLD_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/1/g" >  cold_proline_prot
 awk '{print $1,$4}' COLD_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/1/g" >  cold_aliphatic_prot
 awk '{print $1,$5}' COLD_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/1/g" >  cold_aromatic_prot
 awk '{print $1,$6}' COLD_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/1/g" >  cold_AK_ratio_prot
 awk '{print $1,$7}' COLD_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/1/g" >  cold_tyrosine_prot
 awk '{print $1,$8}' COLD_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/1/g" >  cold_tryptophan_prot
 awk '{print $1,$9}' COLD_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/1/g" >  cold_garvy_prot
#hot proteins for each indices
 awk '{print $1,$2}' HOT_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/-1/g" >  hot_acidic_prot
 awk '{print $1,$3}' HOT_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/-1/g" >  hot_proline_prot
 awk '{print $1,$4}' HOT_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/-1/g" >  hot_aliphatic_prot
 awk '{print $1,$5}' HOT_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/-1/g" >  hot_aromatic_prot
 awk '{print $1,$6}' HOT_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/-1/g" >  hot_AK_ratio_prot
 awk '{print $1,$7}' HOT_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/-1/g" >  hot_tyrosine_prot
 awk '{print $1,$8}' HOT_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/-1/g" >  hot_tryptophan_prot
 awk '{print $1,$9}' HOT_ADAPTATION_SCORE_all_8 | grep "+"  | sed "s/+/-1/g" >  hot_garvy_prot

cat cold_acidic_prot hot_acidic_prot | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' > acidic_cold_hot
cat cold_proline_prot hot_proline_prot | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' > proline_cold_hot
cat cold_aliphatic_prot hot_aliphatic_prot | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' > aliphatic_cold_hot
cat cold_aromatic_prot hot_aromatic_prot | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' > aromatic_cold_hot
cat cold_AK_ratio_prot hot_AK_ratio_prot | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' > AK_ratio_cold_hot
cat cold_tyrosine_prot hot_tyrosine_prot | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' > tyrosine_cold_hot
cat cold_tryptophan_prot hot_tryptophan_prot | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' > tryptophan_cold_hot
cat cold_garvy_prot hot_garvy_prot | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' > garvy_cold_hot


#Neutral_score, cold_score and  hot_score for each protein 

awk '{print $1}' acidic_cold_hot > acidic_cold_hot_ps && grep -Fxvf acidic_cold_hot_ps ALL_ps_LIST |sed 's/$/ 0/g' > neutral_acidic && cat acidic_cold_hot neutral_acidic | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' > acidic_score
awk '{print $1}' proline_cold_hot > proline_cold_hot_ps && grep -Fxvf proline_cold_hot_ps ALL_ps_LIST |sed 's/$/ 0/g' > neutral_proline && cat proline_cold_hot neutral_proline | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' | awk '{print $2}' > proline_score
awk '{print $1}' aliphatic_cold_hot > aliphatic_cold_hot_ps && grep -Fxvf aliphatic_cold_hot_ps ALL_ps_LIST |sed 's/$/ 0/g' > neutral_aliphatic && cat aliphatic_cold_hot neutral_aliphatic | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' | awk '{print $2}' > aliphatic_score
awk '{print $1}' aromatic_cold_hot > aromatic_cold_hot_ps && grep -Fxvf aromatic_cold_hot_ps ALL_ps_LIST |sed 's/$/ 0/g' > neutral_aromatic && cat aromatic_cold_hot neutral_aromatic | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' | awk '{print $2}' > aromatic_score
awk '{print $1}' AK_ratio_cold_hot > AK_ratio_cold_hot_ps && grep -Fxvf AK_ratio_cold_hot_ps ALL_ps_LIST |sed 's/$/ 0/g' > neutral_AK_ratio && cat AK_ratio_cold_hot neutral_AK_ratio | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' | awk '{print $2}' > AK_ratio_score

awk '{print $1}' tyrosine_cold_hot > tyrosine_cold_hot_ps && grep -Fxvf tyrosine_cold_hot_ps ALL_ps_LIST |sed 's/$/ 0/g' > neutral_tyrosine && cat tyrosine_cold_hot neutral_tyrosine | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' | awk '{print $2}' > tyrosine_score
awk '{print $1}' tryptophan_cold_hot > tryptophan_cold_hot_ps && grep -Fxvf tryptophan_cold_hot_ps ALL_ps_LIST |sed 's/$/ 0/g' > neutral_tryptophan && cat tryptophan_cold_hot neutral_tryptophan | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' | awk '{print $2}' > tryptophan_score
awk '{print $1}' garvy_cold_hot > garvy_cold_hot_ps && grep -Fxvf garvy_cold_hot_ps ALL_ps_LIST |sed 's/$/ 0/g' > neutral_garvy && cat garvy_cold_hot neutral_garvy | sed 's/_/\t/g' | sort -nk 2 | sed 's/\t/_/g' | awk '{print $2}' > garvy_score

# Under "cold_hot_neutral_score" file we have a  total no of Hot_proteins, Cold_proteins & Neutral_proteins (count the no of protein and then count at last count independenly Cold, Hot, and Neutral)

paste acidic_score proline_score aliphatic_score aromatic_score AK_ratio_score tyrosine_score tryptophan_score garvy_score | column -t > cold_hot_neutral_score

awk '{print $1,$2,$3,$4,$5,$6,$9}' cold_hot_neutral_score | column -t > cold_hot_neutral_score_6_indi

awk '{for(i=1;i<=NF;i++) t+=$i; print t; t=0}' cold_hot_neutral_score_6_indi > total_count
paste cold_hot_neutral_score_6_indi total_count | column -t > cold_hot_neutral_score_with_count

awk '{if ($8>=3) print $0}' cold_hot_neutral_score_with_count | sed  "1 i\Protien\tAcidic\tProline\tAliphatic\tAromatic\tArg_to_lys\tGravy\ttotal_count" | column -t > COLD_FINAL_SIX_INDICATORS_SCORE
awk '{if ($8<=-3) print $0}' cold_hot_neutral_score_with_count | sed  "1 i\Protien\tAcidic\tProline\tAliphatic\tAromatic\tArg_to_lys\tGravy\ttotal_count" | column -t > HOT_FINAL_SIX_INDICATORS_SCORE
awk '{if ($8<=2 && $8>=-2) print $0}' cold_hot_neutral_score_with_count | sed  "1 i\Protien\tAcidic\tProline\tAliphatic\tAromatic\tArg_to_lys\tGravy\ttotal_count" | column -t > NEUTRAL_FINAL_SIX_INDICATORS_SCORE

########################################################################################################################################################
############################################### EXTRACT NAMES COLD ADAPTATION PROTEIN ##################################################################
########################################################################################################################################################

awk '{print $1}' FINAL_QUERY_MATCH | sed "s/^/grep \"/ g" | sed "s/$/\" query_protein_sequence  /g" > script_extract_query_id_name
sh script_extract_query_id_name > result_query_id_name
paste ps_list result_query_id_name > result_query_id_name_ps


awk '{print $1}' COLD_FINAL_SIX_INDICATORS_SCORE |sed  '1d' > select_COLD_FINAL_SIX_INDICATORS_SCORE_proteins
sed 's/.*/grep -w "&" result_query_id_name_ps/' select_COLD_FINAL_SIX_INDICATORS_SCORE_proteins > script_grep_COLD_SCORE_proteins

sh script_grep_COLD_SCORE_proteins > COLD_ADAPTATED_PROTEIN_NAMES_ps
awk '{$1=""}1' COLD_ADAPTATED_PROTEIN_NAMES_ps | sed "1 i\ id & Protein Name" > COLD_ADAPTATED_PROTEIN_NAMES 

awk '{$1=""}1' COLD_FINAL_SIX_INDICATORS_SCORE |sed 's/-1/-/g' | sed 's/1/+/g' | sed 's/0/*/g'| column -t  > COLD_FINAL_SIX_INDICATORS_SCORE_01

paste COLD_ADAPTATED_PROTEIN_NAMES COLD_FINAL_SIX_INDICATORS_SCORE_01 > COLD_ADAPTATED_PROTEINS_name_score

#######################################################################################################################################################
#################################################### EXTRACT NAMES OF HOT ADAPTATION PROTEIN  #########################################################
#######################################################################################################################################################


awk '{print $1}' HOT_FINAL_SIX_INDICATORS_SCORE |sed  '1d' > select_HOT_FINAL_SIX_INDICATORS_SCORE_proteins
sed 's/.*/grep -w "&" result_query_id_name_ps/' select_HOT_FINAL_SIX_INDICATORS_SCORE_proteins > script_grep_HOT_SCORE_proteins

sh script_grep_HOT_SCORE_proteins > HOT_ADAPTATED_PROTEIN_NAMES_ps
awk '{$1=""}1' HOT_ADAPTATED_PROTEIN_NAMES_ps  | sed "1 i\ id & Protein Name" > HOT_ADAPTATED_PROTEIN_NAMES
 
awk '{print $NF}' HOT_FINAL_SIX_INDICATORS_SCORE > HOT_COUNT 
awk '{$1=""}1' HOT_FINAL_SIX_INDICATORS_SCORE| awk '{$NF=""}1' | sed 's/-1/-/g' | sed 's/1/+/g' | sed 's/0/*/g'| column -t > HOT_FINAL_SIX_INDICATORS_SCORE_01
paste HOT_ADAPTATED_PROTEIN_NAMES HOT_FINAL_SIX_INDICATORS_SCORE_01 HOT_COUNT > HOT_ADAPTATED_PROTEINS_name_score

#########################################################################################################################################################
##################################################### EXTRACT NAMES Neutral PROTEIN  ####################################################################
#########################################################################################################################################################
awk '{print $1}' NEUTRAL_FINAL_SIX_INDICATORS_SCORE |sed  '1d' > select_NEUTRAL_FINAL_SIX_INDICATORS_SCORE_proteins
sed 's/.*/grep -w "&" result_query_id_name_ps/' select_NEUTRAL_FINAL_SIX_INDICATORS_SCORE_proteins > script_grep_NEUTRAL_SCORE_proteins

sh script_grep_NEUTRAL_SCORE_proteins > NEUTRAL_ADAPTATED_PROTEIN_NAMES_ps
awk '{$1=""}1' NEUTRAL_ADAPTATED_PROTEIN_NAMES_ps  | sed "1 i\ id & Protein Name" > NEUTRAL_ADAPTATED_PROTEIN_NAMES
 
awk '{print $NF}' NEUTRAL_FINAL_SIX_INDICATORS_SCORE > NEUTRAL_COUNT 
awk '{$1=""}1' NEUTRAL_FINAL_SIX_INDICATORS_SCORE | awk '{$NF=""}1' | sed 's/-1/-/g' | sed 's/1/+/g' | sed 's/0/*/g'| column -t > NEUTRAL_FINAL_SIX_INDICATORS_SCORE_01
paste NEUTRAL_ADAPTATED_PROTEIN_NAMES  NEUTRAL_FINAL_SIX_INDICATORS_SCORE_01 NEUTRAL_COUNT > NEUTRAL_ADAPTATED_PROTEINS_name_score

#Managing Output files

mkdir RESULT_COLD_HOT_RATIO_AND_SCORE
mv COLD_HOT_RATIO_GRAVY COLD_HOT_RATIO_name COLD_AND_HOT_RATIO_WITH_GRAVY COLD_ADAPTATED_PROTEINS_name_score HOT_ADAPTATED_PROTEINS_name_score NEUTRAL_ADAPTATED_PROTEINS_name_score cold_hot_neutral_score_6_indi RESULT_COLD_HOT_RATIO_AND_SCORE


mkdir molecular_adaptational_analysis
mkdir main_results
mv *.sh calculation* *blastp_output *blastp_output_norepeats *.fasta RESULT_COLD_HOT_RATIO_AND_SCORE query_protein_sequence main_results/
#mv !(*.sh|calculation*|molecular_adaptational_analysis|*blastp_output|*blastp_output_norepeats|*.fasta|RESULT_COLD_HOT_RATIO_AND_SCORE|query_protein_sequence) molecular_adaptational_analysis/
mv * molecular_adaptational_analysis/
mv molecular_adaptational_analysis/main_results/fgcsl.sh $PWD
mkdir Blast_output
mv *blastp_output *blastp_output_norepeats > Blast_output

#results of Cold Hot Ratio and score chart of six indicators

echo "********************************COLD & HOT RATIO RESULTS UNDER "RESULT_COLD_HOT_RATIO_AND_SCORE" Directory(folder)*******************************************"

echo "Your COLD_HOT_RATIO for only Gravy : COLD_HOT_RATIO_GRAVY"
echo "Your COLD_HOT_RATIO without Gravy : COLD_HOT_RATIO_name"
echo "Your COLD_HOT_RATIO with all indicator + Gravy : COLD_AND_HOT_RATIO_WITH_GRAVY"


echo "********************************SCORE RESULTS *********************************************"
echo "COLD_ADAPTATED_PROTEINS_name_score"
echo "HOT_ADAPTATED_PROTEINS_name_score"
echo "NEUTRAL_ADAPTATED_PROTEINS_name_score" 
