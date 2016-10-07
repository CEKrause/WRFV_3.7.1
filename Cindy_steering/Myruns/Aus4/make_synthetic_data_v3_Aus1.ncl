begin

   ;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

   idealDIR = "/g/data1/w85/ett/em_tropical_cyclone_13-09-16/"
   idealDATE = "1989-04-01_00"
   idealRAD = 800. ; km
   metemDIR = "/short/w85/cek156/WRFV_3.7.1/WPS/"

   iSC = 200		; where you want to storm placed in real
   jSC = 350

   iAVG = 210		; this is this area that I used to create an average for the background sounding
   jAVG = 310

   spd = 8.		; m/s
   dirs = 0.
   ;dirs = fspan(0.,360.,9)
   ;dirs = (/120., 150., 180., 210. /)
   ;dirs = (/ 90., 100., 110., 120., 130. /)
   numDIRS = dimsizes(dirs)
   U_avg = new ( numDIRS , float )
   V_avg = new ( numDIRS , float )

   sst = 28. + 273.15

   rad = 4.0*atan(1.0)/180. 
   do ii = 0,numDIRS-1
     U_avg(ii) = -spd*sin(rad*dirs(ii)) 
     V_avg(ii) = -spd*cos(rad*dirs(ii)) 
   end do
   U_avg = where (abs(U_avg) .lt. 0.001 , 0. , U_avg)
   V_avg = where (abs(V_avg) .lt. 0.001 , 0. , V_avg)


   ideal = addfile(idealDIR+"SFC_d01_"+idealDATE+":00:00.nc","r")
   ideal3D = addfile(idealDIR+"PLEVS_d01_"+idealDATE+":00:00.nc","r")
   var = ideal->AFWA_MSLP			; This is for mass points
   dims = dimsizes(var)
   ranks = dimsizes(dims)
   NUMi = dims(ranks-1)
   NUMj = dims(ranks-2)
   SC = NUMi/2 + 1
   start_i = iSC - SC - 2
   end_i = start_i + 249
   start_j = jSC - SC - 2
   end_j = start_j + 249
   print("Storm Center = " + SC)

   dx = var
   dx = 0.
   dy = dx
   distance_mask = dx
   delete(var)

   do ii=0,NUMi-1
     dx(:,:,ii) = abs(ii-SC) 
   end do
   do jj=0,NUMj-1
     dy(:,jj,:) = abs(jj-SC) 
   end do

   distance = 12.0 * (dx^2. + dy^2.)^0.5
   distance_mask = where( distance .lt. idealRAD , 1., 0. ) 

   ;ideal->DX_I = dx
   ;ideal->DY_J = dy
   ;ideal->DIST = distance
   ;ideal->DIST_mask = distance_mask


 do ii = 0,numDIRS-1

   metFILE = "met_em.d01." + idealDATE + ":00:00_i"+iSC+"_j"+jSC+"_spd"+floattoint(spd)+"_dir"+dirs(ii)+".nc"
   system ( "cp " + metemDIR + "met_em.d01." + idealDATE + ":00:00.nc met_em.d01." + idealDATE + ":00:00_original.nc " )
   system ( "cp met_em.d01." + idealDATE + ":00:00_original.nc " + metFILE )

   ;system ( "module load nco" )
   ;system ( "ncrcat -v RH -x " + metFILE + " " + metFILE )

   metem = addfile(metFILE,"w")
   landmask = metem->LANDMASK

   vNames = getfilevarnames (metem) ; Get names of all variables on file
   nNames = dimsizes (vNames)   ; Number of variables on the file

   do n=0,nNames-1

     print("Reading " + vNames(n) )
     var_synthetic = metem->$vNames(n)$
     var_dims = dimsizes(var_synthetic)

     if ( vNames(n) .eq. "PMSL" ) then
       var_avg = avg(var_synthetic(:,jAVG-5:jAVG+5,iAVG-5:iAVG+5))		; 1
       print("   Repalcing " + vNames(n) )
       var_ideal = ideal->AFWA_MSLP 						; 1,250,250
       var_ideal = distance_mask*var_ideal
       var_ideal = where ( var_ideal .eq. 0. , var_avg , var_ideal)
       var_synthetic(:,:,:) = var_avg	 					; var_synthetic = 1,500,500
       var_synthetic(:,start_j:end_j,start_i:end_i) = var_ideal
       metem->$vNames(n)$ = var_synthetic
       delete(var_ideal)
     end if

     if ( vNames(n) .eq. "PSFC" ) then
       print("   Repalcing " + vNames(n) )
       var_avg = avg(var_synthetic(:,jAVG-5:jAVG+5,iAVG-5:iAVG+5))
       var_ideal = ideal->AFWA_MSLP
       var_ideal = distance_mask*var_ideal
       var_ideal = where ( var_ideal .eq. 0. , var_avg , var_ideal)
       foo = var_synthetic
       foo(:,:,:) = var_avg
       foo(:,start_j:end_j,start_i:end_i) = var_ideal
       var_synthetic = where( landmask .eq. 1. , var_synthetic , foo )  	; keep land - was var_synthetic , foo
       delete(foo)
       metem->$vNames(n)$ = var_synthetic
       delete(var_ideal)
     end if
 
    if ( vNames(n) .eq. "SKINTEMP" ) then
       print("   Repalcing " + vNames(n) )
       var_synthetic = where( landmask .eq. 1. , var_synthetic , sst )  	; keep land
       metem->$vNames(n)$ = var_synthetic
     end if

     if ( vNames(n) .eq. "GHT" ) then
       print("   Repalcing " + vNames(n) )
       foo = var_synthetic(:,0,:,:)
       foo = where ( landmask .eq. 0. , foo , -777. ) 		; keep water
       foo@_FillValue = -777.
       var_avg = avg(foo(:,jAVG-5:jAVG+5,iAVG-5:iAVG+5))
       delete(foo)
       var_synthetic(:,0,:,:) = where( landmask .eq. 1. , var_synthetic(:,0,:,:) , var_avg )  	; keep land
       var_ideal = ideal3D->GHT_PL
       do kk = 1,60	; fix code here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         var_avg = avg(var_synthetic(:,kk,jAVG-5:jAVG+5,iAVG-5:iAVG+5))
         var_ideal(:,kk-1,:,:) = distance_mask*var_ideal(:,kk-1,:,:)
         var_ideal(:,kk-1,:,:) = where ( var_ideal(:,kk-1,:,:) .eq. 0. , var_avg , var_ideal(:,kk-1,:,:))
         var_ideal(:,kk-1,:,:) = where ( var_ideal(:,kk-1,:,:) .eq. -999. , var_avg , var_ideal(:,kk-1,:,:))
         var_synthetic(:,kk,:,:) = var_avg
         var_synthetic(:,kk,start_j:end_j,start_i:end_i) = var_ideal(:,kk-1,:,:)
       end do
       do kk = 61,var_dims(1)-1 	; fix code here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         var_avg = avg(var_synthetic(:,kk,jAVG-5:jAVG+5,iAVG-5:iAVG+5))
         var_synthetic(:,kk,:,:) = var_avg
       end do
       metem->$vNames(n)$ = var_synthetic
       delete(var_ideal)
     end if

     if ( vNames(n) .eq. "TT" .or. vNames(n) .eq. "UU" .or. vNames(n) .eq. "VV" .or. vNames(n) .eq. "RH") then
       print("   Repalcing " + vNames(n) )
       var_avg = avg(var_synthetic(:,0,jAVG-5:jAVG+5,iAVG-5:iAVG+5))
       if ( vNames(n) .eq. "TT" ) then
         var_ideal = ideal->T2
         ;var_ideal!2 = "west_east_stag"
       end if
       if ( vNames(n) .eq. "UU" ) then
         var_avg = U_avg(ii)
         var_ideal = ideal->U10
         ;var_ideal!2 = "west_east_stag"
       end if
       if ( vNames(n) .eq. "VV" ) then
         var_avg = V_avg(ii)
         var_ideal = ideal->V10
         ;var_ideal!2 = "west_east_stag"
         ;aaa=getvardims(var_ideal)
         ;print("vardims VV = " + aaa)
       end if
       if ( vNames(n) .eq. "RH" ) then
         var_ideal = ideal->Q2
         ;var_ideal!2 = "west_east_stag"
         t2 = ideal->T2
         psfc = ideal->AFWA_MSLP
         q2 = var_ideal
         tmp1 = var_ideal
         tmp2 = var_ideal
         tmp1 = 10.*0.6112*exp(17.67*(t2-273.16)/(t2-29.65))
         tmp2 = 0.622*tmp1/(0.01 * psfc -  (1.-0.622)*tmp1)
         var_ideal = q2/tmp2
         var_ideal = where ( var_ideal .gt. 1.0 , 1.0 , var_ideal)
         var_ideal = where ( var_ideal .lt. 0.0 , 0.0 , var_ideal)
         var_ideal = 100.*var_ideal
         delete ( ([/t2,psfc,q2,tmp1,tmp2/]) )
       end if
       var_ideal = distance_mask*var_ideal
       ;aaa=getvardims(var_ideal)
       ;print("vardims VV = " + aaa)
       var_ideal = where ( var_ideal .eq. 0. , var_avg , var_ideal)
       var_synthetic(:,0,:,:) = var_avg      
       var_synthetic(:,0,start_j:end_j,start_i:end_i) = (/var_ideal/)
       delete(var_ideal)
       if ( vNames(n) .eq. "TT" ) then
         var_ideal = ideal3D->T_PL
       end if
       if ( vNames(n) .eq. "UU" ) then
         var_ideal = ideal3D->U_PL
       end if
       if ( vNames(n) .eq. "VV" ) then
         var_ideal = ideal3D->V_PL
       end if
       if ( vNames(n) .eq. "RH" ) then
         var_ideal = ideal3D->RH_PL
       end if

       var_synthetic(:,1,:,:) = var_synthetic(:,0,:,:)

       do kk = 2,60	; fix code here!!!!!!!!!!!!!!!!!!!!!!
         var_avg = avg(var_synthetic(:,kk,jAVG-5:jAVG+5,iAVG-5:iAVG+5))
         if ( vNames(n) .eq. "UU" ) then
           var_avg = U_avg(ii)
         end if
         if ( vNames(n) .eq. "VV" ) then
           var_avg = V_avg(ii)
         end if
         var_ideal(:,kk-1,:,:) = distance_mask*var_ideal(:,kk-1,:,:)
         var_ideal(:,kk-1,:,:) = where ( var_ideal(:,kk-1,:,:) .eq. 0. , var_avg , var_ideal(:,kk-1,:,:))
         var_ideal(:,kk-1,:,:) = where ( var_ideal(:,kk-1,:,:) .eq. -999. , var_avg , var_ideal(:,kk-1,:,:))
         if ( vNames(n) .eq. "RH" ) then
           var_ideal(:,kk-1,:,:) = where ( var_ideal(:,kk-1,:,:) .lt.  var_avg/2. , var_avg , var_ideal(:,kk-1,:,:))
         end if
         var_synthetic(:,kk,:,:) = var_avg
         var_synthetic(:,kk,start_j:end_j,start_i:end_i) = (/var_ideal(:,kk-1,:,:)/)
       end do
       do kk = 61,var_dims(1)-1 	; fix code here!!!!!!!!!!!!!!!!!!!
         var_avg = avg(var_synthetic(:,kk,jAVG-5:jAVG+5,iAVG-5:iAVG+5))
         if ( vNames(n) .eq. "UU" ) then
           var_avg = U_avg(ii)
         end if
         if ( vNames(n) .eq. "VV" ) then
           var_avg = V_avg(ii)
         end if
         var_synthetic(:,kk,:,:) = var_avg
       end do
       metem->$vNames(n)$ = var_synthetic
       delete(var_ideal)
     end if

     delete(var_synthetic)
     delete(var_dims)

   end do

 end do


end
