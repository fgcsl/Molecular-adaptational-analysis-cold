#print "\n\n\t\#################### Count the number of acidic/basic/neutral amino acids #################### \n\n";
#print "This script will count the number of acidic/basic/neutral amino acids\n\n";
use strict;

#variables
my $count_of_acidic=0;
my $count_of_proline=0;
my $count_of_aliphatic=0;
my $count_of_aromatic=0;
my $count_of_arginine=0;
my $count_of_lysine=0;
#my $count_of_phenylalanine=0;
my $count_of_tyrosine=0;
my $count_of_tryptophan=0;
#my $count_of_serine=0;
#my $count_of_glycine=0;
#my $count_of_polar=0;
#my $count_of_electrically_charged=0;

my @prot;
my $prot_filename;
my $line;
my $sequence;
my $aa;
my $cmd;
my $ratio;
my $cnt;
my $prot;
#print "PLEASE ENTER THE FILENAME OF THE PROTEIN SEQUENCE:=";
chomp($prot_filename=$ARGV[0]);

open(PROTFILE,$prot_filename) or die "unable to open the file";
@prot=<PROTFILE>;
close PROTFILE;


foreach $line (@prot) {

# discard blank line
if ($line =~ /^\s*$/) {
next;

# discard comment line
} elsif($line =~ /^\s*#/) {
next;

# discard fasta header line
} elsif($line =~ /^>/) {
next;

# keep line, add to sequence string
} else {
$sequence .= $line;
}
}

# remove non-sequence data (in this case, whitespace) from $sequence string
$sequence =~ s/\s//g;
#print "$sequence\n";
my $cnt = map $_, $sequence =~ /(.)/gs;


@prot=split("",$sequence); #splits string into an array
#print " \nThe original PROTEIN file is:\n$sequence \n";
#$cmd = system q(awk '{ print length($0); }' <;
#print $cmd;


while(@prot){
$aa = shift (@prot);
if($aa =~/[DNEQ]/ig){
$count_of_acidic++;
}
if($aa=~/[P]/ig){
$count_of_proline++;
}
if($aa=~/[VILA]/ig){
$count_of_aliphatic++;
}
if($aa=~/[WY]/ig){
$count_of_aromatic++;
}
if($aa=~/[R]/ig){
$count_of_arginine++;
}
if($aa=~/[K]/ig){
$count_of_lysine++;
}
if($aa=~/[Y]/ig){
$count_of_tyrosine++;
}
if($aa=~/[W]/ig){
$count_of_tryptophan++;
}

#if($aa=~/[S]/ig){
#$count_of_serine++;
#}

#if($aa=~/[G]/ig){
#$count_of_glycine++;
#}

#if($aa=~/[STCYNQ]/ig){
#$count_of_polar++;
#}

#if($aa=~/[DEKRH]/ig){
#$count_of_electrically_charged++;
#}


}

my $ratio_Arginine_lysine = $count_of_arginine/$count_of_lysine;
my $acidic_frequency = $count_of_acidic/$cnt;
my $proline_frequency = $count_of_proline/$cnt;
my $aliphatic_frequency = $count_of_aliphatic/$cnt;
my $aromatic_frequency = $count_of_aromatic/$cnt;
my $tyrosine_frequency = $count_of_tyrosine/$cnt;
my $tryptophan_frequency = $count_of_tryptophan/$cnt;
#my $serine_frequency = $count_of_serine/$cnt;
#my $glycine_frequency = $count_of_glycine/$cnt;
#my $polar_frequency = $count_of_polar/$cnt;
#my $electrically_charged_frequency = $count_of_electrically_charged/$cnt;


#my $cnt = @{[$prot =~ /(\.)/g]};
#print "$cnt\
print "$acidic_frequency\n";		#1st_indicator
print "$proline_frequency\n";		#2nd_indicator
print "$aliphatic_frequency\n";		#3rd_indicator
print "$aromatic_frequency\n";		#4th_indicator
print "$ratio_Arginine_lysine\n";	#5th_indicator
print "$tyrosine_frequency\n";		#7th_indicator
print "$tryptophan_frequency\n";	#8th_indicator
#print "$serine_frequency\n";		#9th_indicator
#print "$glycine_frequency\n";		#10th_indicator
#print "$polar_frequency\n";		#11th_indicator
#print "$electrically_charged_frequency\n"; #12st_indicator
#Gravy                                    #13th_indicator


#print "\nNumber of phenylalanine amino acids:".$count_of_phenylalanine."\n";
#print "Number of tyrosine amino acids:".$count_of_tyrosine."\n";
#print "Number of tryptophan amino acids:".$count_of_tryptophan."\n";
                          


