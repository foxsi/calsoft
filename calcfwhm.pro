;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION CALCFWHM, HIST, ASIC = ASIC, CH = CH, RANGE=RANGE, $
                   EPEAK = EPEAK, REBIN=REBIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  if not keyword_set(asic) then asic=0
  if not keyword_set(ch) then ch=0
  if not keyword_set(range) then range=[0,1000]
  if not keyword_set(rebin) then rebin=1

  dx = hist(1,0,0,0)*0.0001
;  dx = hist(1000,0,0,0)*0.0001

  xtemp = rebin2(hist[*, ch, asic, 0],rebin)
  ytemp = rebin2(hist[*, ch, asic, 1],rebin)
  sz = (size(xtemp))[1]

  draw_hist,hist,asic,ch,xrange=range,rebin=rebin
 xx=[0.]
 yy=[0.]

  for bin = 0, sz-1 do begin
      if xtemp[bin] gt range[0] and xtemp[bin] lt range[1] then begin
          xx=[xx,xtemp[bin]]
          yy=[yy,ytemp[bin]]
      endif
  endfor

  xx=xx[indgen((size(xx))(1)-1)+1]
  yy=yy[indgen((size(yy))(1)-1)+1]
  xxsz = (size(xx))[1]

  peak=max(spline(xx,yy,findgen(100000)/100000.*(xx[xxsz-2]-xx[1])+xx[1]))
  peakx=(where(spline(xx,yy,findgen(100000)/100000.*(xx[xxsz-2]-xx[1])+xx[1]) eq peak))[0]$
    /100000.*(xx[xxsz-2]-xx[1])+xx[1]

  if not keyword_set(epeak) then epeak = peakx


  x1=(where(spline(xx,yy,findgen(100)/100.*(peakx-range[0])+range[0]) gt peak/2.))[0]$
    /100.*(peakx-range[0])+range[0]

  xold=0.
  while(abs(x1-xold) gt dx) do begin
      temp = x1
      dfdx = (spline(xx,yy,x1+dx)-spline(xx,yy,x1-dx))/dx/2.
      x1=x1-(spline(xx,yy,x1)-peak/2.)/dfdx
      xold=temp
;      print, x1, xold, dx, spline(xx,yy,x1), dfdx
  endwhile

  x2=(where(spline(xx,yy,findgen(100)/100.*(range[1]-peakx)+peakx) lt peak/2.))[0]$
    /100.*(range[1]-peakx)+peakx

  xold=0.
  while(abs(x2-xold) gt dx) do begin
      temp = x2
      dfdx = (spline(xx,yy,x2+dx)-spline(xx,yy,x2-dx))/dx/2.
      x2=x2-(spline(xx,yy,x2)-peak/2.)/dfdx
      xold=temp
;      print, x2, xold, spline(xx,yy,x2), dfdx
  endwhile

  gain = epeak / peakx
  fwhm = (x2 - x1) * gain
  print, 'peak channel: ', peakx
  print, 'gain: ', gain
  print, 'FWHM: ', fwhm

  return, fwhm
  
END
