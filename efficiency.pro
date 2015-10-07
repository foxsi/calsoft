;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO EFFICIENCY, VTH=VTH, FILES=FILES, BADCH=BADCH, SAVEFILE = SAVEFILE, STOP=STOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

n=(size(vth))[1]
rate=fltarr(2,n)
for i=0, n-1 do begin
    print, 'Processing ', files[i]
    rate[*,i]=countrate_fe_func(files[i],/cmn_median,badch=badch)
endfor


 window, xsize = 800, ysize = 600
!p.multi=[0,1,2]

func='P[0]*ERFC((X-P[1])/P[2]/sqrt(2.))'
start=[4.,20.,3.]
result=MPFITEXPR(func, vth, rate[0,*], rate[1,*], start)
ploterr, vth, rate[0,*], rate[1,*], xrange=[0,30],yrange=[0,max(rate[0,*])+1],psym=1, $
	xtitle = 'Threshold value', ytitle = 'Rate in 5.9 keV peak', thick=4
xx=findgen(300)/10.
oplot, xx,  result[0]*ERFC((xx-result[1])/result[2]/sqrt(2.))

gain=5.9/result[1]
sigma=result[2]*gain
ee=findgen(100)/10.
effic=(erf((ee-12.*gain)/sigma)+1)/2.
plot,ee,effic, $
	xtitle = 'Energy [keV]', ytitle = 'Efficiency', thick=4


print, 'gain :',gain, '   keV / Vth '
print, 'E =', gain*15., '   at Vth = 12'
print, 'sigma :',result[2],'   Vth '
print, 'sigma :',sigma,'   keV '
print, 'efficiency :', effic[20]*100.,'   %   at 2 keV'
print, 'efficiency :', effic[30]*100.,'   %   at 3 keV'
print, 'efficiency :', effic[40]*100.,'   %   at 4 keV'
print, 'efficiency :', effic[50]*100.,'   %   at 5 keV'
print, 'efficiency :', effic[60]*100.,'   %   at 6 keV'
print, 'efficiency :', effic[70]*100.,'   %   at 7 keV'

if keyword_set(savefile) then begin
  energy_kev = ee
  efficiency = effic
  save, energy_kev, efficiency, file = savefile
endif

if keyword_set(stop) then stop

END
