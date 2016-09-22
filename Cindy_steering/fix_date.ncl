load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

       ;new_date = "2006-03-21_00:00:00"

       A  = addfile (DIR+"/met_em.d01."+new_date+".nc","w")
       var = A->Times
       print("Time in file " + var)
       vard = stringtochar(new_date)
       var(0,:) = (/vard(0:18)/)
       print("Time in file " + var)
       A->Times = var
       delete(var)

end

