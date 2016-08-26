#!/bin/csh
set echo

set tmpDIR = "tmpDIR"

#foreach case ( i550_j230_spd10_dir120 i550_j230_spd10_dir150 i550_j230_spd10_dir180 i550_j230_spd10_dir210 i550_j230_spd5_dir120 i550_j230_spd5_dir150 i550_j230_spd5_dir180 i550_j230_spd5_dir210 i550_j250_spd10_dir120 i550_j250_spd10_dir150 i550_j250_spd10_dir180 i550_j250_spd10_dir210 i550_j250_spd5_dir120 i550_j250_spd5_dir150 i550_j250_spd5_dir180 i550_j250_spd5_dir210 i600_j230_spd10_dir120 i600_j230_spd10_dir150 i600_j230_spd10_dir180 i600_j230_spd10_dir210 i600_j230_spd5_dir120 i600_j230_spd5_dir150 i600_j230_spd5_dir180 i600_j230_spd5_dir210 i600_j250_spd10_dir120 i600_j250_spd10_dir150 i600_j250_spd10_dir180 i600_j250_spd10_dir210 i600_j250_spd5_dir120 i600_j250_spd5_dir150 i600_j250_spd5_dir180 i600_j250_spd5_dir210 )

#foreach case ( i542_j254_spd10.3093_dir210 i542_j256_spd10.3093_dir210 i542_j258_spd10.3093_dir210 i544_j254_spd10.3093_dir210 i544_j256_spd10.3093_dir210 i544_j258_spd10.3093_dir210 i546_j254_spd10.3093_dir210 i546_j256_spd10.3093_dir210 i546_j258_spd10.3093_dir210 )
#foreach case ( i505_j250_spd10_dir90 i505_j250_spd10_dir100 i505_j250_spd10_dir110 i505_j250_spd10_dir120 i505_j250_spd10_dir130 )
#foreach case ( noSTORM_noLAND_100 noSTORM_noLAND_130 )
#foreach case ( STORM_noLAND_i505_j250_spd5_dir100 STORM_noLAND_i550_j246_spd5_dir210 STORM_flatLAND_i505_j250_spd5_dir100 STORM_flatLAND_i550_j246_spd5_dir210 noSTORM_noLAND_210 )
#foreach case ( noSTORM_LAND_100 noSTORM_LAND_130 noSTORM_LAND_210 )
#foreach case ( i505_j250_spd5_dir100_shear10 i505_j250_spd5_dir100_shear6 i550_j246_spd5_dir210_shear10 i550_j246_spd5_dir210_shear6 )
foreach case ( new_profile_i505_j250_spd5_dir100 new_profile_i550_j246_spd5_dir210 )

  #mkdir /glade/scratch/bruyerec/IAG/planetCindy/${case}
  set tmpDIR = "/glade/scratch/bruyerec/IAG/WRFV3.6.1_intel_dmpar/test/em_real/"${case}
  
  set fil = "met_em.d01.2006-03-18_00:00:00_${case}.nc"
  set Date = "2006-03"
  set sDD = 18
  set eDD = 23
  set DD = $sDD
  
  while ( ${DD} <= ${eDD} )
    foreach HH ( "00" "06" "12" "18" )
      set newDate = ${Date}"-"${DD}"_"${HH}":00:00"
      echo "Working on " ${newDate}
      #cp ${fil} ${case}/met_em.d01.${newDate}.nc
      #ncl fix_date.ncl DIR=\"${case}\" new_date=\"${newDate}\"
      cp ${fil} ${tmpDIR}/met_em.d01.${newDate}.nc
      ncl fix_date.ncl DIR=\"${tmpDIR}\" new_date=\"${newDate}\"
    end
    @ DD = ${DD} + 1
  end

  #mv ${tmpDIR}/met* /glade/scratch/bruyerec/IAG/planetCindy/${case}/.

end
