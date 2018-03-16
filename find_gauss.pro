;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION FIND_GAUSS, XAXIS, HIST, LD, UD, DX, REBIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

xtemp=rebin2(xaxis,rebin)
htemp=rebin2(hist,rebin)
htemp2=htemp

for i=0, (size(htemp))(1)-1 do begin
    if xtemp[i] lt ld or xtemp[i] gt ud then htemp[i]=0.
endfor

maxbin=(where(htemp eq max(htemp)))(0)

integ=0.
norm=0.

if maxbin lt dx then maxbin=dx+1

for i=maxbin-dx, maxbin+dx do begin
    integ+=htemp2[i]*xtemp[i]
    norm+=htemp2[i]
endfor
peak=integ/norm


coeff=[max(htemp),peak,0.1]
;coeff=[1,(peaks(6, ch, asic, 0)),5]
;selin=where(htemp eq 0.)

;selin=where(htemp ne 0)
if ((strtrim(string(peak),2) eq 'NaN') or (strtrim(string(peak),2) eq '-NaN') or (peak le 0)) then peak = 5
selin=where((xaxis ge peak-6) and (xaxis le peak+6))
;selin=where((xtemp ge (peak-8)) and $
;	    ((xtemp le (peak+8))))
	selxx=xaxis[selin]
	selyy=hist[selin]
	;selxx=xtemp[selin]
	;selyy=htemp[selin]
	coeff=[max(selyy),(peak),4]
	est=coeff
p = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]},(3))
p(1).limited(0)=1
p(1).limits(0)=peak-2  ; centroid checks
p(1).limited(1)=1
p(1).limits(1)=peak+2 ;centroid checks


diff=abs(selxx-peak)
diffindex = where(diff eq min(diff))

grad_forward = selyy[diffindex+1]-selyy[diffindex]
grad_backward = selyy[diffindex-1]-selyy[diffindex]
;if ((grad_forward lt 0) and (grad_backward lt 0) and (selyy[diffindex-1] ne 0.) and (selyy[diffindex+1] ne 0.)) then print,'athray'
;if(grad_forward

;stop

if(n_elements(selxx) gt 1) then begin
	;gfit=mpfitpeak(selxx,selyy,coeff,estimates=est,nterms=3,sigma=si,measure_errors=sqrt(selyy))
	gfit=mpfitpeak(selxx,selyy,coeff,parinfo=p,estimates=est,nterms=3,sigma=si,error=sqrt(selyy),chisq=chi,dof=dof)
	;gfit=mpfitpeak(xtemp,htemp,coeff,parinfo=p,estimates=est,nterms=3,sigma=si,measure_errors=sqrt(htemp))
	;plot,selxx,selyy
	ploterr,selxx,selyy,sqrt(selyy),psym=4
	oplot,selxx,gfit,linestyle=0,psym=0
	LEGEND,['Data','Fit'],psym=[4,0],box=2,charsize=0.5,charthick=2
	;cgtext,coeff[1]-5,10,string(chi/float(dof)),/data,charsize=0.8
	;help,chi
	;print,chi/float(dof),dof
	;print,peak-coeff[1],si[1]
	;if ((abs(peak-coeff[1]) lt 2) and (si[1] gt 0.) and (si[1] lt 3.)) then print,peak,coeff[1],si[1] else print, peak
	if ((si[1] gt 0.) and (si[1] lt 3.)) then fitpar = [coeff[1],si[1]] else fitpar= [peak,0.]
endif else fitpar=[0,0]
;print,fitpar
;stop
return, fitpar

END
