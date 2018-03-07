; IDL procedure by Athiray
; Copyright (c) 2017, FOXSI Mission University of Minnesota.  All rights reserved.
;       Unauthorized reproduction is allowed.


; Start		: 18 Apr 2017 23:33
; Last Mod 	: 27 Oct 2017 15:02

;-------------------  Details of the program --------------------------;

function quad,x,par
quadfit =(par[0]*x^2)+(par[1]*x)+par[2]
return,quadfit
end
function linear,x,par
linearfit =(par[0]*x)+par[1]
return,linearfit
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO DRAW_64ECQUAD, PEAKS, ASIC, MAKEPLOT, XRANGE = XRANGE, YRANGE = YRANGE
;PRO DRAW_64ECQUAD, PEAKS, ERROR, ASIC, XRANGE = XRANGE, YRANGE = YRANGE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if not keyword_set(xrange) then xrange = [0, 1024]
  if not keyword_set(yrange) then yrange = [0,30]
 ; peaks = [peaks[0:2,*,*,*],peaks[4:*,*,*,*]]
 quadfit_par=dblarr(3,64,4)
 nl=dblarr(8,64,4)
 quad_residual=dblarr(8,64,4)
 quad_ratio=dblarr(8,64,4)

 ;;nside
 for asic=0,3 do begin
      if asic gt 1 then xr=9 else xr=7
      IF  makeplot eq 'y' then begin
	  ;!p.multi=[0,4,4]
	  !p.multi=[0,2,2]
	  !X.MARGIN=!X.MARGIN/1.2
	  !Y.MARGIN=!Y.MARGIN/1.
	  set_plot,'PS'
	  fname='Gaincal_quadfit_asic'+strtrim(string(asic),2)+'.eps'
	  device,filename=fname,/color
      endif
      ;!p.multi = [0, 8, 8]
      ;redchi_as2=fltarr(64)
      ;redchi_as3=fltarr(64)
      for ch = 0, 63 do begin

	  ;Fit using mpcurve fit - quadratic function
	  gpar=[1,1,1]
	  err=intarr(n_elements(peaks[2:xr, ch, asic,0]))+1.
	  qres=mpfitfun('quad',peaks[2:xr, ch, asic,0], peaks[2:xr,ch,asic,1],$
	      err,gpar,perror=sig,/weights)
	  mo=qres[0]*peaks[2:xr, ch, asic,0]^2+qres[1]*peaks[2:xr, ch, asic,0]+qres[2]
	  ;plot, peaks[2:xr, ch, asic,0], peaks[2:xr, ch, asic, 1],$
	   ;   xrange = [0,400], yrange = [0,30], psym = 4;,$
	      ;thick=1.5
	  ;oplot, peaks[2:xr, ch, asic,0], peaks[2:xr, ch, asic, 1],psym=2
	  ;oplot,peaks[2:xr, ch, asic,0],mo,thick=2
	 ; if asic eq 2 then redchi_as2[ch]=total((peaks[2:xr,ch,asic,1]-mo)^2)/5.
	 ; if asic eq 3 then redchi_as3[ch]=total((peaks[2:xr,ch,asic,1]-mo)^2)/5.

	 ;======
	 ;=====FIT USING LINFIT =====
	 linres=linfit(peaks[2:xr, ch, asic,0],peaks[2:xr, ch, asic, 1],yfit=yval)
	 nl[0:n_elements(yval)-1,ch,asic] = (yval-peaks[2:xr, ch, asic, 1])/peaks[2:xr, ch, asic, 1]

	 ;==== FIT USING POLYFIT idl routine ======
	 loadct,11
	 if (asic eq 2 and ch gt 62) then  peaks[2:xr,ch,asic,0]=peaks[2:xr,ch-1,asic]
	 if (asic eq 3 and ch lt 1) then  peaks[2:xr,ch,asic,0]=peaks[2:xr,ch+2,asic]
	 polyres = poly_fit(peaks[2:xr, ch, asic,0], peaks[2:xr,ch,asic,1],2,$
	     sigma=polysi,chisq=polychi,yerror=polyerr,yfit=polyfit,status=state)
	 if(state eq 0) then print,polyres,polychi,state else print,'athray'
	 quadfit_par[*,ch,asic]=polyres
	 quad_ratio[0:n_elements(polyfit)-1,ch,asic] = (polyfit/peaks[2:xr, ch, asic, 1])
	 quad_residual[0:n_elements(polyfit)-1,ch,asic] = (polyfit-peaks[2:xr, ch, asic, 1])/peaks[2:xr, ch, asic, 1]
         if (asic le 1) then tit = 'n-side (ASIC '+strtrim(string(asic),2)+')' else tit='p-side (ASIC '+strtrim(string(asic),2)+')'

	 ;if(asic le 1) then xran=[0,450] else xran=[0,750]
	 plot, peaks[2:xr, ch, asic,0], peaks[2:xr, ch, asic, 1],$
	     xrange = xrange, yrange = yrange, psym = 4,thick=3,title=tit,$
	     ;xrange = xran, yrange = [0,60], psym = 4,thick=2,$
	     xthick=5,ythick=5,charsize=1.25,charthick=4
	 oplot,peaks[2:xr-1,ch,asic,0],polyfit,thick=4,color=120
	 val='Channel ' + strtrim(string(ch),2)
	 legend,val,box=0,/right,charsize=1.15,charthick=5,font=1,/bottom
	 if (ch mod 16 eq 15) then begin
	     cgtext,0.5,0.005,'ADC Channel',/normal,$
		 font=1,orientation=0,charsize=1.52,charthick=3
	     cgtext,0.0195,0.5,'Energy (keV)',/normal,$
		 font=1,orientation=90,charsize=1.52,charthick=3
	     ;;cgtext,0.5,0.98,'ASIC '+strtrim(string(asic),2),/normal,$
		;; font=1,orientation=0,charsize=2,charthick=2
	 endif
     endfor
     if makeplot eq 'y' then begin
	 device,/close
	 set_plot,'x'


	 if asic ge 2 then begin
	 !p.multi=[0,0,0]
	 ;!p.multi=[0,2,4]
	 set_plot,'PS'
	 fname='nonlinearity_asic'+strtrim(string(asic),2)+'.eps'
	 device,filename=fname,/color
	 if (asic eq 2) then yr=[0:61]
	 if (asic eq 3) then yr=[2:63]
	 loadct,11
	 plot,nl[0,yr,asic],ytitle='Residual',psym=10,$
	     thick=3,xthick=3,ythick=3,$
	     xra=[0,65],xst=1,yra=[-0.1,0.30],$
	     charsize=1.5,charthick=2,xtitle='Strip No.'
	 oplot,nl[1,yr,asic],psym=10,thick=3,color=120
	 oplot,nl[2,yr,asic],psym=10,thick=3,color=150
	 oplot,nl[3,yr,asic],psym=10,thick=3,color=200
	 legval=['5.89 keV','7.46 keV','8.04 keV','13.9 keV']
	 legcol=[0,120,150,200]
	 legend,legval,colors=legcol,box=0,linestyle=[0,0,0,0],/right,$
	     thick=3,charsize=0.98,charthick=2

	 oplot,nl[4,yr,asic],psym=10,thick=3,linestyle=2,color=200
	 oplot,nl[5,yr,asic],psym=10,thick=3,linestyle=2,color=150
	 oplot,nl[6,yr,asic],psym=10,thick=3,linestyle=2,color=120
	 oplot,nl[7,yr,asic],psym=10,thick=3,linestyle=2,color=0

	 legval1=['17.7 keV','20.7 keV','26.3 keV','59.6 keV']
	 legcol1=[200,150,120,0]
	 legls  =[2,2,2,2]
	 legend,legval1,colors=legcol1,box=0,linestyle=legls,/left,$
	     thick=3,charsize=0.98,charthick=2

	 device,/close
	 set_plot,'x'
     	 endif

	 if asic lt 2 then begin
	 ;!p.multi=[0,2,3]
	 !p.multi=[0,0,0]
	 set_plot,'PS'
	 fname='nonlinearity_asic'+strtrim(string(asic),2)+'.eps'
	 device,filename=fname
	 yr=[0:63]
	 ;plot,nl[0,yr,asic],ytitle='NL',title='5.89kev',psym=10
	 ;plot,nl[1,yr,asic],ytitle='NL',title='7.41kev',psym=10
	 ;plot,nl[2,yr,asic],ytitle='NL',title='8.04kev',psym=10
	 ;plot,nl[3,yr,asic],ytitle='NL',title='13.9kev',psym=10
	 ;plot,nl[4,yr,asic],ytitle='NL',title='17.7kev',psym=10
	 ;plot,nl[5,yr,asic],ytitle='NL',title='59.6kev',psym=10


	 loadct,11
	 plot,nl[0,yr,asic],ytitle='Residual',psym=10,$
	     thick=3,xthick=3,ythick=3,$
	     xra=[0,65],xst=1,yra=[-0.1,0.30],$
	     charsize=1.5,charthick=2,xtitle='Strip No.'
	 oplot,nl[1,yr,asic],psym=10,thick=3,color=120
	 oplot,nl[2,yr,asic],psym=10,thick=3,color=150
	 oplot,nl[3,yr,asic],psym=10,thick=3,color=200
	 legval=['5.89 keV','7.46 keV','8.04 keV','13.9 keV']
	 legcol=[0,120,150,200]
	 legend,legval,colors=legcol,box=0,linestyle=[0,0,0,0],/right,$
	     thick=3,charsize=0.98,charthick=2

	 oplot,nl[4,yr,asic],psym=10,thick=3,linestyle=2,color=200
	 oplot,nl[5,yr,asic],psym=10,thick=3,linestyle=2,color=150

	 legval1=['17.7 keV','59.6 keV']
	 legcol1=[200,150]
	 legls  =[2,2]
	 legend,legval1,colors=legcol1,box=0,linestyle=legls,/left,$
	     thick=3,charsize=0.98,charthick=2

	 device,/close
	 set_plot,'x'
    	 endif
     endif
     ;if makeplot eq 'y' then begin
	 ;device, /close
	 ;set_plot,'x'
     ;endif
 endfor

 for asic=0,3 do begin
      if asic gt 1 then xr=9 else xr=7
      IF  makeplot eq 'y' then begin
	  !X.MARGIN=!X.MARGIN/0.95
	  !Y.MARGIN=!Y.MARGIN/1.
	  !p.multi=[0,2,2]
	  set_plot,'PS'
	  fname='Gaincal_quadratio_asic'+strtrim(string(asic),2)+'.eps'
	  device,filename=fname,/color
      endif
         if (asic le 1) then tit = 'n-side (ASIC '+strtrim(string(asic),2)+')' else tit='p-side (ASIC '+strtrim(string(asic),2)+')'

      for ch=0,63 do begin
	  plot, peaks[2:xr, ch, asic,1], quad_ratio[0:(xr-2),ch, asic],$
	     ;xrange = [0,60],yr=[min(quad_ratio[0:(xr-2),ch,asic]),$
	     xrange = yrange,yr=[0.85,1.15],$
	     psym = 4,thick=3,$
	     ;xrange = yrange,yr=[min(quad_ratio[0:(xr-2),ch,asic]),$
	     ;max(quad_ratio[0:(xr-2),ch, asic])], psym = 4,thick=3,$
	     xthick=5,ythick=5,charsize=1.25,charthick=4,yticks=2,title=tit
	 val='Channel ' + strtrim(string(ch),2)
	 legend,val,box=0,/right,charsize=1.15,charthick=5,font=1,/bottom

	 if (ch mod 16 eq 15) then begin
	     cgtext,0.5,0.005,'Energy (keV)',/normal,$
		 font=1,orientation=0,charsize=1.52,charthick=3
	     cgtext,0.0195,0.5,'Model/Data',/normal,$
		 font=1,orientation=90,charsize=1.52,charthick=3
	     ;cgtext,0.5,0.98,'ASIC '+strtrim(string(asic),2),/normal,$
		; font=1,orientation=0,charsize=2,charthick=2
	 endif
     endfor
     if((asic eq 0) or (asic eq 2)) then print,'ASIC',asic,' fit uncertainty',     min(quad_ratio[0:xr-2,0:61,asic]),' - ', max(quad_ratio[0:xr-2,0:61,asic])
     if((asic eq 1) or (asic eq 3)) then print,'ASIC',asic,' fit uncertainty',     min(quad_ratio[0:xr-2,2:63,asic]),' - ', max(quad_ratio[0:xr-2,2:63,asic])
      if((asic eq 0) or (asic eq 2)) then begin
	  for i =0,xr-2 do print,$
	      mean(quad_ratio[i,0:61,asic]),stddev(quad_ratio[i,0:61,asic]),$
	      abs(mean(quad_ratio[i,0:61,asic])-1)*100.
      endif
      if((asic eq 1) or (asic eq 3)) then begin
	  for i =0,xr-2 do print,$
	      mean(quad_ratio[i,2:63,asic]),stddev(quad_ratio[i,2:63,asic]),$
	      abs(mean(quad_ratio[i,2:63,asic])-1)*100.
      endif



 endfor
 device,/close
 set_plot,'x'


 !p.multi=[0,2,2]
     set_plot,'ps'
     fname='quadratio_histogram.eps'
     device,filename=fname,/encapsulated

 for asic=0,3 do begin
      if asic gt 1 then xr=9 else xr=7
      if (asic le 1) then title = 'n-side' else title='p-side'
     if((asic eq 0) or (asic eq 2)) then $
	 cghistoplot,quad_ratio[0:xr-2,0:61,asic],thick=4,title=title,xthick=4,ythick=4,charthick=3,charsize=1.25,color='blue',font=1,yticks=4 $
     else $
     cghistoplot,quad_ratio[0:xr-2,2:63,asic],thick=4,title=title,charsize=1.25,charthick=3,xthick=4,ythick=4,color='blue',font=1,yticks=4
     legend,'ASIC '+ strtrim(string(asic),2),box=0,thick=3,charthick=3,charsize=1.2,font=1,/right
     cgtext,0.5,0.01,'Model/Data',/normal,$
		 font=1,orientation=0,charsize=1.52,charthick=3

 endfor
     device,/close
     set_plot,'x'

 !p.multi=[0,2,2]
     set_plot,'ps'
     fname='fe_quadratio_histogram.eps'
     device,filename=fname,/encapsulated

      for asic=0,3 do begin
      if asic gt 1 then xr=10 else xr=8
      if (asic le 1) then title = 'n-side' else title='p-side'
     if((asic eq 0) or (asic eq 2)) then $
	 cghistoplot,quad_ratio[0,0:61,asic],thick=4,title=title,xthick=4,ythick=4,charthick=3,charsize=1.25,color='blue',font=1,yticks=4 $
     else $
     cghistoplot,quad_ratio[0,2:63,asic],thick=4,title=title,charsize=1.25,charthick=3,xthick=4,ythick=4,color='blue',font=1,yticks=4
     legend,'ASIC '+ strtrim(string(asic),2),box=0,thick=3,charthick=3,charsize=1.2,font=1,/right
     legend,'5.89 keV',box=0,thick=3,charthick=3,charsize=1.2,font=1,/left
     cgtext,0.5,0.01,'Model/Data',/normal,$
		 font=1,orientation=0,charsize=1.52,charthick=3

 endfor
     device,/close
     set_plot,'x'


    !p.multi=[0,2,2]
     set_plot,'ps'
     fname='ni_quadratio_histogram.eps'
     device,filename=fname,/encapsulated

      for asic=0,3 do begin
      if asic gt 1 then xr=10 else xr=8
      if (asic le 1) then title = 'n-side' else title='p-side'
     if((asic eq 0) or (asic eq 2)) then $
	 cghistoplot,quad_ratio[1,0:61,asic],thick=4,title=title,xthick=4,ythick=4,charthick=3,charsize=1.25,color='blue',font=1,yticks=4 $
     else $
     cghistoplot,quad_ratio[1,2:63,asic],thick=4,title=title,charsize=1.25,charthick=3,xthick=4,ythick=4,color='blue',font=1,yticks=4
     legend,'ASIC '+ strtrim(string(asic),2),box=0,thick=3,charthick=3,charsize=1.2,font=1,/right
     legend,'7.46 keV',box=0,thick=3,charthick=3,charsize=1.2,font=1,/left
     cgtext,0.5,0.01,'Model/Data',/normal,$
		 font=1,orientation=0,charsize=1.52,charthick=3

 endfor
     device,/close
     set_plot,'x'


	  !X.MARGIN=!X.MARGIN/0.8
	  !Y.MARGIN=!Y.MARGIN/0.95

   !p.multi=[0,2,2]
     set_plot,'ps'
     fname='cu_quadratio_histogram.eps'
     device,filename=fname,/encapsulated

      for asic=0,3 do begin
      if asic gt 1 then xr=10 else xr=8
      if (asic le 1) then title = 'n-side' else title='p-side'
     if((asic eq 0) or (asic eq 2)) then $
	 cghistoplot,quad_ratio[2,0:61,asic],thick=4,title=title,xthick=4,ythick=4,charthick=3,charsize=1.25,color='blue',font=1,yticks=4 $
     else $
     cghistoplot,quad_ratio[2,2:63,asic],thick=4,title=title,charsize=1.25,charthick=3,xthick=4,ythick=4,color='blue',font=1,yticks=4
     legend,'ASIC '+ strtrim(string(asic),2),box=0,thick=3,charthick=3,charsize=1.2,font=1,/right
     legend,'8.04 keV',box=0,thick=3,charthick=3,charsize=1.2,font=1,/left
     cgtext,0.5,0.01,'Model/Data',/normal,$
		 font=1,orientation=0,charsize=1.52,charthick=3

 endfor
     device,/close
     set_plot,'x'

  !p.multi=[0,2,2]
     set_plot,'ps'
     fname='am_quadratio_histogram.eps'
     device,filename=fname,/encapsulated

      for asic=0,3 do begin
      if asic gt 1 then xr=10 else xr=8
      if (asic le 1) then title = 'n-side' else title='p-side'
     if((asic eq 0) or (asic eq 2)) then $
	 cghistoplot,quad_ratio[3,0:61,asic],thick=4,title=title,xthick=4,ythick=4,charthick=3,charsize=1.25,color='blue',font=1,yticks=4 $
     else $
     cghistoplot,quad_ratio[3,2:63,asic],thick=4,title=title,charsize=1.25,charthick=3,xthick=4,ythick=4,color='blue',font=1,yticks=4
     legend,'ASIC '+ strtrim(string(asic),2),box=0,thick=3,charthick=3,charsize=1.2,font=1,/right
     legend,'13.9 keV',box=0,thick=3,charthick=3,charsize=1.2,font=1,/left
     cgtext,0.5,0.01,'Model/Data',/normal,$
		 font=1,orientation=0,charsize=1.52,charthick=3

 endfor
     device,/close
     set_plot,'x'


 stop
 save,quadfit_par,file='quadfit_par.sav'
 stop
END






































;if not keyword_set(xrange) then xrange = [0, 1024]
  ;if not keyword_set(yrange) then yrange = [0,100]
 ;; peaks = [peaks[0:2,*,*,*],peaks[4:*,*,*,*]]
 ;quadfit_par=dblarr(3,64,4)
 ;nl=dblarr(8,64,4)
  ;for asic_no=0,1 do begin
      ;asic=asic_no+2
      ;IF  makeplot eq 'y' then begin
	  ;!p.multi=[0,4,4]
	  ;set_plot,'PS'
	  ;fname='Gaincal_quadfit_asic'+strtrim(string(asic),2)+'.eps'
	  ;device,filename=fname,/color
      ;endif
      ;;!p.multi = [0, 8, 8]
      ;redchi_as2=fltarr(64)
      ;redchi_as3=fltarr(64)
      ;for ch = 0, 63 do begin

	  ;;Fit using mpcurve fit - quadratic function
	  ;gpar=[1,1,1]
	  ;err=intarr(n_elements(peaks[2:9, ch, asic,0]))+1.
	  ;qres=mpfitfun('quad',peaks[2:9, ch, asic,0], peaks[2:9,ch,asic,1],$
	      ;err,gpar,perror=sig,/weights)
	  ;mo=qres[0]*peaks[2:9, ch, asic,0]^2+qres[1]*peaks[2:9, ch, asic,0]+qres[2]
	  ;;plot, peaks[2:9, ch, asic,0], peaks[2:9, ch, asic, 1],$
	   ;;   xrange = [0,400], yrange = [0,30], psym = 4;,$
	      ;;thick=1.5
	  ;;oplot, peaks[2:9, ch, asic,0], peaks[2:9, ch, asic, 1],psym=2
	  ;;oplot,peaks[2:9, ch, asic,0],mo,thick=2
	 ;; if asic eq 2 then redchi_as2[ch]=total((peaks[2:9,ch,asic,1]-mo)^2)/5.
	 ;; if asic eq 3 then redchi_as3[ch]=total((peaks[2:9,ch,asic,1]-mo)^2)/5.

	 ;;======
	 ;;=====FIT USING LINFIT =====
	 ;linres=linfit(peaks[2:9, ch, asic,0],peaks[2:9, ch, asic, 1],yfit=yval)
	 ;nl[*,ch,asic] = (yval-peaks[2:9, ch, asic, 1])/peaks[2:9, ch, asic, 1]


	 ;;==== FIT USING POLYFIT idl routine ======
	 ;loadct,11
	 ;polyres = poly_fit(peaks[2:9, ch, asic,0], peaks[2:9,ch,asic,1],2,$
	     ;sigma=polysi,chisq=polychi,yerror=polyerr,yfit=polyfit,status=state)
	 ;if(state eq 0) then print,polyres,polychi,state else print,'athray'
	 ;quadfit_par[*,ch,asic]=polyres
	 ;plot, peaks[2:9, ch, asic,0], peaks[2:9, ch, asic, 1],$
	     ;xrange = [0,400], yrange = [0,30], psym = 4,thick=2,$
	     ;xthick=3,ythick=3
	 ;oplot,peaks[2:9, ch, asic,0],polyfit,thick=3,color=120
	 ;if (ch mod 16 eq 15) then begin
	     ;cgtext,0.5,0.01,'ADC Channel',/normal,$
		 ;font=1,orientation=0,charsize=1,charthick=2
	     ;cgtext,0.015,0.5,'Energy (keV)',/normal,$
		 ;font=1,orientation=90,charsize=1,charthick=2
	     ;cgtext,0.5,0.98,'ASIC '+strtrim(string(asic),2),/normal,$
		 ;font=1,orientation=0,charsize=1,charthick=2
	 ;endif
     ;endfor
     ;if makeplot eq 'y' then begin
	 ;device,/close
	 ;set_plot,'x'
	 ;!p.multi=[0,2,4]
	 ;set_plot,'PS'
	 ;fname='nonlinearity_asic'+strtrim(string(asic),2)+'.eps'
	 ;device,filename=fname
	 ;if (asic eq 2) then yr=[0:61]
	 ;if (asic eq 3) then yr=[2:63]
	 ;plot,nl[0,yr,asic],ytitle='NL',title='5.9kev',psym=10
	 ;plot,nl[1,yr,asic],ytitle='NL',title='7.48kev',psym=10
	 ;plot,nl[2,yr,asic],ytitle='NL',title='8.04kev',psym=10
	 ;plot,nl[3,yr,asic],ytitle='NL',title='13.9kev',psym=10
	 ;plot,nl[4,yr,asic],ytitle='NL',title='17.7kev',psym=10
	 ;plot,nl[5,yr,asic],ytitle='NL',title='20.7kev',psym=10
	 ;plot,nl[6,yr,asic],ytitle='NL',title='26.3kev',psym=10
	 ;plot,nl[7,yr,asic],ytitle='NL',title='59.6kev',psym=10
     ;endif
  ;device,/close
  ;set_plot,'x'

     ;stop
 ;endfor
 ;save,quadfit_par,file='quadfit_par.sav'
 ;stop
;END



