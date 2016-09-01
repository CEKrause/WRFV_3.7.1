load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
	A = addfile("wrfinput_d01","w")
	varU = A->U
	varU = varU * -1
	A->U = varU
        
        varV = A->V
        varV = varV * -1
        A->V = varV

end
