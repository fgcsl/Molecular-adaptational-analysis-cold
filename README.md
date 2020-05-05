# Molecular adaptational analysis

The Molecular adaptational analysis were done on the bases of Six indices (referred to as cold-adaptor indicators) namely- frequency of acidic residues; proline residues; aromaticity; aliphacity; grand average of hydrophobicity (GRAVY); and the ratio of arginine (R) and lysine (K) were calculated to estimate cold adaptation at amino-acid level. 



## Requirement
#### 1. Standalone blast software
Required standalone blast software on your own computer, you will need to download the BLAST+ software  To see the instructions and get the latest version of BLAST+, go to the
stant alone blast+
(https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/)

#### 2. python2

#### 3. pip
Pip is a package management system that simplifies installation and management of software packages written in Python
```
$ sudo apt-get install python-pip
```
#### 4. Biopython
```
$ pip install biopython
```
## Steps

#### Step 1: Input

Add query sequence file into query directory and subjects sequence files into  a subject directory make sure file’s name should be end with ".fasta"
(In our case we add 13 mesophilic as a subject and a one psychrotolerant as a query . In the third step protein blast will done from one query (psychrotolerant) with 13 subjects (mesophilic) independently)

```
$ cp query_file.fasta cold_adaptation_shell_scripts/query .
$ cp subject_file.fasta cold_adaptation_shell_scripts/subject .

```
#### Step 2: Remove Hypothetical Proteins from your query sequence 

To remove Hypothetical Protein Sequence from your query file by running shell script "shell_remove_hypo_sequence.sh":
run
```
*You need to make the shell script executable using chmod command
$chmod +x shell_remove_hypo_sequence.sh

$ ./shell_remove_hypo_sequence.sh 
it will ask for :													
Enter your fasta file from remove hypothetical_sequence: enter your_query_file_name (example:arthrobacter_sp.MWB30.fasta)	
then,														
Give output file name for  Non-hypothetical sequences:   give_output_name_non_hypo (eg: abc)
```
#### Step 3: Molecular Analysis: Cold-Hot ratio & Score of Cold Hot and Neutral proteins 
Change your directory to subject directory
```
$cd  ../subject
```
Run "fgcsl.sh" script. you need to wait for result it will take 3 to 4 hours or more depends on your proteins sequence. 
```
*You need to make the shell script executable using chmod command
$chmod +x shell_remove_hypo_sequence.sh

*Note : Blast output fomat was "-outfmt 6" and evalue cutoff was set to 1e-15; if you want to change the parameters it can me changed at line no 12

$  ./fgcsl.sh

```
#### "calculation_perl_program_frquency_12.pl" is a perl program which is use to calculate the frequency of amino acids indicators
  							
<br />

## Results


#### Results Under "RESULT_COLD_HOT_RATIO_AND_SCORE" Directory 
```
Your COLD_HOT_RATIO for only Gravy : "COLD_HOT_RATIO_GRAVY"
Your COLD_HOT_RATIO without Gravy : "COLD_HOT_RATIO_name"
Your COLD_HOT_RATIO with all indicator + Gravy : "COLD_AND_HOT_RATIO_WITH_GRAVY"
```

#### Score results (Cold, Hot and Neutral proteins name)
```
No of Cold adaptated proteins : "COLD_ADAPTATED_PROTEINS_name_score"
No of Hold adaptated proteins : "HOT_ADAPTATED_PROTEINS_name_score"
No of Neutral adaptated proteins : "NEUTRAL_ADAPTATED_PROTEINS_name_score"
```
To see whole molecular analysis results go to the "molecular_adaptational_analysis" Directory 
			

Please don't hesitate to post on *Issues* or contact me (khatriabhi2319@gmail.com) for help.
