#!/bin/bash
# reads from the TRAN file($tran)
# and convert data to FRESCO input file($fresco)

echo "Enter the tran file name"
read tran
#tran="tran.ge80dp1halfp"

index=0

#### Reading TRAN file Begin ##################################
while read line ; do
 index=$(($index+1))
 larray[$index]="$line"
done < $tran

for (( i=1; i<=$index; i++ ))
do
 ifs=' ' read -a array <<< "${larray[$i]}"
 
 if [ $i -eq 1 ]; then
  fname="tran.${array[${#array[@]}-1]}"
  fresco="${array[${#array[@]}-1]}.in"
 elif [ $i -eq 2 ]; then
  rmax=${array[2]}
  dr=0.1
  nrmin=1
  nrmax=${array[4]}
  ielab=${array[5]}
  ielabpa=`echo "" | awk "{ print ${ielab}/2}"`
  iqvleu=0
 elif [ $i -eq 3 ]; then
  tlspin=$( printf "%.0f" ${array[2]} )
  tjspin=${array[3]}
 elif [ $i -eq 4 ]; then
  inonlocal=${array[4]}
 elif [ $i -eq 5 ]; then
  ipmas=${array[1]}
  ipspn=${array[5]}
  ipz=${array[3]}
  itmas=${array[2]}
  itspn=${array[6]}
  itz=${array[4]}
 elif [ $i -eq 6 ]; then
  iv=${array[1]}
  iwdwisd=${array[2]}
  ivso=${array[3]}
  iwso=${array[4]}
  ir0=${array[5]}
  iar=${array[6]}
  irc=${array[7]}
 elif [ $i -eq 7 ]; then
  irsor=${array[1]}
  iasor=${array[2]}
  irsoi=${array[3]}
  iasoi=${array[4]}
 elif [ $i -eq 8 ]; then
  icsdg=${array[1]}
  iri=${array[2]}
  iai=${array[3]}
 elif [ $i -eq 9 ]; then
  npw=${array[2]}
  fnonlocal=${array[4]}
  ilmin=0
  ilmax=${npw}
  flmin=0
  flmax=${npw}
 elif [ $i -eq 10 ]; then
  fpmas=${array[1]}
  ftmas=${array[2]}
  fpz=${array[3]}
  ftz=${array[4]}
  fpspn=${array[5]}
  ftspn=${array[6]}
  fqvleu=${array[7]}
 elif [ $i -eq 11 ]; then
  fv=${array[1]}
  fwdwisd=${array[2]}
  fvso=${array[3]}
  fwso=${array[4]}
  fr0=${array[5]}
  far=${array[6]}
  frc=${array[7]}
 elif [ $i -eq 12 ]; then
  frsor=${array[1]}
  fasor=${array[2]}
  frsoi=${array[3]}
  fasoi=${array[4]}
 elif [ $i -eq 13 ]; then
  fcsdg=${array[1]}
  fri=${array[2]}
  fai=${array[3]}
  fdr=${array[4]}
 elif [ $i -eq 14 ]; then
  angmax=${array[1]}
  angstep=${array[2]}
  angmin=${array[3]}
 elif [ $i -eq 17 ]; then
  fnrng=${array[1]}
 elif [ $i -eq 18 ]; then
  tnod=`echo "" | awk "{ print ${array[1]}+1}"`
  tbe=${array[3]}
  tm2=${array[4]}
  tm1=${fpmas}
  tsspin=${array[6]}
 elif [ $i -eq 19 ]; then
  br0=${array[1]}
  brc=${array[2]}
  bar=${array[3]}
  bvso=${array[4]}
  bv=${fv}
  brso=${br0}
  baso=${bar}
 fi
done
iwd=`echo "" | awk "{ print ${iwdwisd}*(1-${icsdg})}"`
iwisd=`echo "" | awk "{ print ${iwdwisd}-${iwd}}"`
fwd=`echo "" | awk "{ print ${fwdwisd}*(1-${fcsdg})}"`
fwisd=`echo "" | awk "{ print ${fwdwisd}-${fwd}}"`
#### Reading TRAN file End ####################################

#### Reding additional information for FRESCO Begin ################
echo "Enter the name of beam nucleus"
read inamep 
#inamep="d"
echo "Enter the name of target nucleus"
read inamet 
#inamet="Ge80"
echo "Enter the name of ejectile nucleus"
read fnamep 
#fnamep="p"
echo "Enter the name of recoile nucleus"
read fnamet 
#fnamet="Ge81"
echo "Enter the Q-value(MeV) of the ground state of recoile nucleus"
read qvaluegs
#qvaluegs=2.635
bedeut=2.224573
echo "Choose the treatment of range of <d|p> vertex:"
echo "(1 for zero-range , 2 for local-energy approximation and 3 for finite range)"
read rangetype 
#rangetype=3
fnrng=0
fnrngopt=""
if [ $rangetype -eq 1 ]; then
 rangetype=5
elif [ $rangetype -eq 2 ]; then
 rangetype=5
 fnrng=0.745712
elif [ $rangetype -eq 3 ]; then
 rangetype=7
 fnrngopt="ip1=0 ip2=-1 ip3=5"
fi

ipprty=1
itprty=1
fpprty=1
ftprty=1

ipex=0.0
itex=0.0
fpex=0.0
ftex=`echo "" | awk "{ print ${qvaluegs}-${fqvleu}}"`

#### Reding additional information for FRESCO End ##################

#### Generating FRESCO file Begin ##################################
##### General Information
echo "${title} l=$( printf "%.0f" $tlspin ) Transfer Reaction @ ${ielabpa}MeV/A" > $fresco
echo "NAMELIST">>$fresco
echo "&FRESCO hcm=${dr} rmatch=${rmax} rintp=0.1 hnl=0.1 rnl=6.5 centre=0.0">>$fresco
echo "        jtmin=0.0 jtmax=35.0 absend=-1.0">>$fresco
echo "        thmin=${angmin} thmax=${angmax} thinc=${angstep}">>$fresco
echo "        iter=1 chans=1 nnu=${npw} xstabl=1">>$fresco
echo "        elab=${ielab} /">>$fresco
echo "">>$fresco

##### Partition for incoming and outgoing
echo "&PARTITION namep='${inamep}' massp=${ipmas} zp=${ipz} namet='${inamet}' masst=${itmas} zt=${itz} nex=-1 /">>$fresco
echo "&STATES jp=${ipspn} bandp=${ipprty} ep=${ipex} cpot=1 jt=${itspn} bandt=${itprty} et=${itex} /">>$fresco
echo "">>$fresco
echo "&PARTITION namep='${fnamep}' massp=${fpmas} zp=${fpz} namet='${fnamet}' masst=${ftmas} zt=${ftz} qval=${fqvleu} nex=1 /">>$fresco
echo "&STATES jp=${fpspn} bandp=${fpprty} ep=${fpex} cpot=2 jt=${ftspn} bandt=${ftprty} et=${ftex} /">>$fresco
echo "&partition /">>$fresco
echo "">>$fresco

##### Potentials
echo "&POT kp=1 at=${itmas} rc=${irc} /">>$fresco
echo "&POT kp=1 type=1 p1=${iv} p2=${ir0} p3=${iar} p4=${iwd} p5=${ir0} p6=${iar} /">>$fresco
echo "&POT kp=1 type=2 p1=0.0 p2=${iri} p3=${iai} p4=${iwisd} p5=${iri} p6=${iai} /">>$fresco
echo "&POT kp=1 type=3 p1=${ivso} p2=${irsor} p3=${iasor} /">>$fresco
echo "">>$fresco

echo "&POT kp=2 at=${ftmas} rc=${frc} /">>$fresco
echo "&POT kp=2 type=1 p1=${fv} p2=${fr0} p3=${far} p4=${fwd} p5=${fr0} p6=${far} /">>$fresco
echo "&POT kp=2 type=2 p1=0.0 p2=0.0 p3=0.0 p4=${fwisd} p5=${fri} p6=${fai} /">>$fresco
echo "&POT kp=2 type=3 p1=${fvso} p2=${frsor} p3=${fasor} /">>$fresco
echo "">>$fresco

echo "&POT kp=3 at=${itmas} rc=${irc} /">>$fresco
echo "&POT kp=3 type=1 p1=${bv} p2=${br0} p3=${bar} /">>$fresco
echo "&POT kp=3 type=3 p1=${bvso} p2=${brso} p3=${baso} /">>$fresco
echo "">>$fresco

echo "&POT kp=4 type=1 shape=5 p1=1 p3=1 /">>$fresco
echo "&POT kp=4 type=3 shape=5 p1=1 p3=1 /">>$fresco
echo "&POT kp=4 type=4 shape=5 p1=1 p3=1 /">>$fresco
echo "&POT kp=4 type=7 shape=5 p1=1 p3=1 /">>$fresco
echo "">>$fresco

echo "&POT kp=5 at=${itmas} rc=${frc} /">>$fresco
echo "&POT kp=5 type=1 p1=${fv} p2=${fr0} p3=${far} p4=${fwd} p5=${fr0} p6=${far} /">>$fresco
echo "&POT kp=5 type=2 p1=0.0 p2=0.0 p3=0.0 p4=${fwisd} p5=${fri} p6=${fai} /">>$fresco
echo "&POT kp=5 type=3 p1=${fvso} p2=${frsor} p3=${fasor} /">>$fresco
echo "">>$fresco
echo "&pot/">>$fresco
echo "">>$fresco

##### Overlaps for transfer reaction
echo "&Overlap kn1=1 kn2=2 ic1=2 ic2=1 in=1 kind=3 nn=1 l=0 lmax=2 sn=${fpspn} j=0.5 kbpot=4 be=${bedeut} isc=1 ipc=0 /">>$fresco
echo "&Overlap kn1=3 kn2=4 ic1=1 ic2=2 in=2 kind=0 nn=${tnod} l=${tlspin} sn=${fpspn} j=${tjspin} kbpot=3 be=${tbe} isc=1 ipc=0 /">>$fresco
echo "&overlap /">>$fresco
echo "">>$fresco

##### Couplings for transfer reaction
echo "&Coupling icto=-2 icfrom=1 kind=${rangetype} ${fnrngopt} p1=-122.5 p2=${fnrng}/">>$fresco
echo "&CFP in=1 ib=1 ia=1 kn=1 a=1.000 /">>$fresco
echo "&CFP in=2 ib=1 ia=1 kn=3 a=1.000 /">>$fresco
echo "&cfp /">>$fresco
echo "&coupling /">>$fresco
echo "">>$fresco
#### Generating FRESCO file End ####################################

echo "${fresco} file created! Bye!"
