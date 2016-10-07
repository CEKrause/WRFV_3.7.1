#!/bin/csh
set echo

set tmpDIR = "tmpDIR"

foreach case (i200_j300_spd8_dir0)

  mkdir ${case}
  #set tmpDIR = "/glade/scratch/bruyerec/IAG/WRFV3.6.1_intel_dmpar/test/em_real/"${case}
  
  set fil = "met_em.d01.1989-04-01_00:00:00_${case}.nc"
  #set Date = "1989-03"
  #set sDD = 26
  #set eDD = 31
  set Date = "1989-04"
  set sDD = 10
  set eDD = 30

  set DD = $sDD
  
  while ( ${DD} <= ${eDD} )
    foreach HH ( "00" "06" "12" "18" )
      set newDate = ${Date}"-"${DD}"_"${HH}":00:00"
      echo "Working on " ${newDate}
      cp ${fil} ${case}/met_em.d01.${newDate}.nc
      ncl fix_date.ncl DIR=\"${case}\" new_date=\"${newDate}\"
      #cp ${fil} ${tmpDIR}/met_em.d01.${newDate}.nc
      #ncl fix_date.ncl DIR=\"${tmpDIR}\" new_date=\"${newDate}\"
    end
    @ DD = ${DD} + 1
  end

  #mv ${tmpDIR}/met* /glade/scratch/bruyerec/IAG/planetCindy/${case}/.

end

