PRO FWHM, HIST=HIST, FILE=FILE

if keyword_set(file) then hist=makehist(file)

asic=0
xx0=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 0)
yy0=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 1)
result=gaussfit(xx0,yy0,coeff0)
fwhm0=2.35*coeff0[2]
asic=1
xx1=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 0)
yy1=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 1)
result=gaussfit(xx1,yy1,coeff1)
fwhm1=2.35*coeff1[2]
asic=2
xx2=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 0)
yy2=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 1)
result=gaussfit(xx2,yy2,coeff2)
fwhm2=2.35*coeff2[2]
asic=3
xx3=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 0)
yy3=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 1)
result=gaussfit(xx3,yy3,coeff3)
fwhm3=2.35*coeff3[2]
print,''
print,'FWHM for ASICs 0,1,2,3:'
print,fwhm0,fwhm1,fwhm2,fwhm3
print,''

if keyword_set(file) then begin

hist=makehist(file,/cmn_median)
asic=0
xx0=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 0)
yy0=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 1)
result=gaussfit(xx0,yy0,coeff0)
fwhm0=2.35*coeff0[2]
asic=1
xx1=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 0)
yy1=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 1)
result=gaussfit(xx1,yy1,coeff1)
fwhm1=2.35*coeff1[2]
asic=2
xx2=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 0)
yy2=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 1)
result=gaussfit(xx2,yy2,coeff2)
fwhm2=2.35*coeff2[2]
asic=3
xx3=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 0)
yy3=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 1)
result=gaussfit(xx3,yy3,coeff3)
fwhm3=2.35*coeff3[2]
print,''
print,'FWHM for ASICs 0,1,2,3, common-mode subtracted:'
print,fwhm0,fwhm1,fwhm2,fwhm3
print,''

endif

END
