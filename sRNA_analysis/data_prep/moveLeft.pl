use warnings;
use strict; 

my $filename;
my $R1;
my $R2;
my $pos=1000000000;
my @R1_line;
my @R2_line;
my @R1_toPrint;
@R1_toPrint=("ID", 0, "NC", $pos);
my @R2_toPrint;
@R2_toPrint=("ID", 0, "NC", $pos);

#open(FH, '<', $filename) or die $!;

while(1){
  #$R1=<FH>; 
  #$R1=$_; 
  $R1=<>;
  last unless defined $R1;
  #$R2=<FH>;
  #$R2=$_;
  $R2=<>;
  last unless defined $R2;
  chomp($R1);
  chomp($R2);
  @R1_line=split("\t", $R1);
  @R2_line=split("\t", $R2);
  if($R1_line[0] ne $R2_line[0]) {exit} ;
  if($R1_toPrint[0] eq "ID") {@R1_toPrint = @R1_line; @R2_toPrint = @R2_line;}
  if(($R1_line[0] ne $R1_toPrint[0])) {
    if($R1_toPrint[1] == 339) {$R1_toPrint[1] = 83}
    if($R1_toPrint[1] == 419) {$R1_toPrint[1] = 163}
    if($R2_toPrint[1] == 339) {$R2_toPrint[1] = 83}
    if($R2_toPrint[1] == 419) {$R2_toPrint[1] = 163}
    if($R1_toPrint[1] == 355) {$R1_toPrint[1] = 99}
    if($R1_toPrint[1] == 403) {$R1_toPrint[1] = 147}
    if($R2_toPrint[1] == 355) {$R2_toPrint[1] = 99}
    if($R2_toPrint[1] == 403) {$R2_toPrint[1] = 147}
    $R1_toPrint[4] = 60;
    $R2_toPrint[4] = 60;
    print join("\t", @R1_toPrint);
    print "\n";
    print join("\t", @R2_toPrint);
    print "\n";
    @R1_toPrint = @R1_line;
    @R2_toPrint = @R2_line;
    } else {
      if($R1_line[3] < $R1_toPrint[3]) {@R1_toPrint=@R1_line; @R2_toPrint=@R2_line;}
#      print "KEICIU\n";\
    }
  }

  if($R1_toPrint[1] == 339) {$R1_toPrint[1] = 83}
  if($R1_toPrint[1] == 419) {$R1_toPrint[1] = 163}
  if($R2_toPrint[1] == 339) {$R2_toPrint[1] = 83}
  if($R2_toPrint[1] == 419) {$R2_toPrint[1] = 163}
  if($R1_toPrint[1] == 355) {$R1_toPrint[1] = 99}
  if($R1_toPrint[1] == 403) {$R1_toPrint[1] = 147}
  if($R2_toPrint[1] == 355) {$R2_toPrint[1] = 99}
  if($R2_toPrint[1] == 403) {$R2_toPrint[1] = 147}
  $R1_toPrint[4] = 60;
  $R2_toPrint[4] = 60;
  print join("\t", @R1_toPrint);
  print "\n";
  print join("\t", @R2_toPrint);
  print "\n";


#close(FH);
