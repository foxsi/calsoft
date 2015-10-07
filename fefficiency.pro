;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO FEFFICIENCY, VTH=VTH, FILES=FILES, BADCH=BADCH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

n=(size(vth))[1]
rate=fltarr(2,n)
for i=0, n-1 do begin
    rate[*,i]=countrate_simple(files[i],badch=badch)
endfor

print,'countrate: ',rate[0,*]
print,'error: ',rate[1,*]

 window, xsize = 800, ysize = 600
!p.multi=[0,1,2]

func='P[0]*(8.5*ERFC((X-P[1]*5.888)/P[2]/sqrt(2.))+16.9*ERFC((X-P[1]*5.899)/P[2]/sqrt(2.))+2.99*ERFC((X-P[1]*6.490)/P[2]/sqrt(2.)))'


start=[0.9,3.,3.]
result=MPFITEXPR(func, vth, rate[0,*], rate[1,*], start, perror=perror)
print, 'parameter errors: ',perror
mm1=max(rate[0,*])+max(rate[1,*])
mm=mm1>result[0]*(8.5+16.9+2.99)*2.
ploterr, vth, rate[0,*], rate[1,*], xrange=[0,30],yrange=[0,mm],psym=1
xx=findgen(300)/10.
oplot, xx, result[0]*(8.5*ERFC((xx-result[1]*5.888)/result[2]/sqrt(2.))+16.9*ERFC((xx-result[1]*5.899)/result[2]/sqrt(2.))+2.99*ERFC((xx-result[1]*6.490)/result[2]/sqrt(2.)))

gain=1.0/(result[1])
sigma=(result[2])*gain
ee=findgen(100)/10.

gain_err=perror[1]/result[1]^2
sigma_err=perror[2]*gain

pi=3.1415926536

df=exp(-0.5*((ee-15.*gain)/sigma)^2)/sqrt(pi)
err1=df*(ee-15.*gain)/sigma^2/sqrt(2)*sigma_err
err2=df*15./sqrt(2)/sigma*gain_err
efficerr=sqrt(err1^2+err2^2)

effic=(erf((ee-15.*gain)/sigma/sqrt(2))+1)/2.

df=exp(-0.5*((ee-15.*gain)/sigma)^2)/sqrt(pi)
err1=df*(ee-15.*gain)/sigma^2/sqrt(2)*sigma_err
err2=df*15./sqrt(2)/sigma*gain_err
effic_err=sqrt(err1^2+err2^2)


effic10=(erf((ee-10.*gain)/sigma/sqrt(2))+1)/2.

df=exp(-0.5*((ee-10.*gain)/sigma)^2)/sqrt(pi)
err1=df*(ee-10.*gain)/sigma^2/sqrt(2)*sigma_err
err2=df*10./sqrt(2)/sigma*gain_err
effic10_err=sqrt(err1^2+err2^2)


effic12=(erf((ee-12.*gain)/sigma/sqrt(2))+1)/2.

df=exp(-0.5*((ee-12.*gain)/sigma)^2)/sqrt(pi)
err1=df*(ee-12.*gain)/sigma^2/sqrt(2)*sigma_err
err2=df*12./sqrt(2)/sigma*gain_err
effic12_err=sqrt(err1^2+err2^2)


plot,ee,effic
oplot, ee, effic10, linestyle=1


print, 'gain :',gain, '   keV / Vth '
print, 'E =', gain*12., '   at Vth = 12'
print, 'E =', gain*15., '   at Vth = 15'
print, 'sigma :',result[2],'   Vth '
print, 'sigma :',sigma,'   keV '
print, ' '
print, 'Vth = 15 efficiency'
print, 'efficiency :', effic[20]*100.,' +-',effic_err[40]*100,'   %   at 2 keV'
print, 'efficiency :', effic[30]*100.,' +-',effic_err[40]*100,'   %   at 3 keV'
print, 'efficiency :', effic[40]*100.,' +-',effic_err[40]*100,'   %   at 4 keV'
print, 'efficiency :', effic[50]*100.,' +-',effic_err[50]*100,'   %   at 5 keV'
print, 'efficiency :', effic[60]*100.,' +-',effic_err[60]*100,'   %   at 6 keV'
print, 'efficiency :', effic[70]*100.,' +-',effic_err[70]*100,'   %   at 7 keV'
print, ' '
print, 'Vth = 12 efficiency'
print, 'efficiency :', effic12[20]*100.,' +-',effic12_err[40]*100,'   %   at 2 keV'
print, 'efficiency :', effic12[30]*100.,' +-',effic12_err[40]*100,'   %   at 3 keV'
print, 'efficiency :', effic12[40]*100.,' +-',effic12_err[40]*100,'   %   at 4 keV'
print, 'efficiency :', effic12[50]*100.,' +-',effic12_err[50]*100,'   %   at 5 keV'
print, 'efficiency :', effic12[60]*100.,' +-',effic12_err[60]*100,'   %   at 6 keV'
print, 'efficiency :', effic12[70]*100.,' +-',effic12_err[70]*100,'   %   at 7 keV'
print, ' '
print, 'Vth = 10 efficiency'
print, 'efficiency :', effic10[20]*100.,' +-',effic10_err[40]*100,'   %   at 2 keV'
print, 'efficiency :', effic10[30]*100.,' +-',effic10_err[40]*100,'   %   at 3 keV'
print, 'efficiency :', effic10[40]*100.,' +-',effic10_err[40]*100,'   %   at 4 keV'
print, 'efficiency :', effic10[50]*100.,' +-',effic10_err[50]*100,'   %   at 5 keV'
print, 'efficiency :', effic10[60]*100.,' +-',effic10_err[60]*100,'   %   at 6 keV'
print, 'efficiency :', effic10[70]*100.,' +-',effic10_err[70]*100,'   %   at 7 keV'
print, ' '
print, 'focal4kev15=[focal4keV15,',effic[40]*100.,']'
print, 'focal5kev15=[focal5keV15,',effic[50]*100.,']'
print, 'focal6kev15=[focal6keV15,',effic[60]*100.,']'
print, 'focal4kev12=[focal4keV12,',effic12[40]*100.,']'
print, 'focal5kev12=[focal5keV12,',effic12[50]*100.,']'
print, 'focal6kev12=[focal6keV12,',effic12[60]*100.,']'

print, 'focal4kev15_err=[focal4keV15_err,',effic_err[40]*100.,']'
print, 'focal5kev15_err=[focal5keV15_err,',effic_err[50]*100.,']'
print, 'focal6kev15_err=[focal6keV15_err,',effic_err[60]*100.,']'
print, 'focal4kev12_err=[focal4keV12_err,',effic12_err[40]*100.,']'
print, 'focal5kev12_err=[focal5keV12_err,',effic12_err[50]*100.,']'
print, 'focal6kev12_err=[focal6keV12_err,',effic12_err[60]*100.,']'



END
