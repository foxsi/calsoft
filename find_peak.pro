;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION FIND_PEAK, XAXIS, HIST, LD, UD, DX, REBIN
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

  return, peak
  
END
