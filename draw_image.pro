;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO DRAW_IMAGE, IMG, ASIC, NMAX=NMAX, NMIN=NMIN, XRANGE=XRANGE, YRANGE=YRANGE, $
	nowindow = nowindow, _extra=_extra
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;if not keyword_set(xrange) then xrange = [0, 1023]
  if not keyword_set(nmax) then nmax=max(img)
  if not keyword_set(nmin) then nmin=min(img)

  if not keyword_set(nowindow) then window, xsize = 600, ysize = 600

!p.multi=[0,1,1]

;loadct2,1, /reverse
loadct,1
tvlct,r,g,b,/get
r[0] = 1*255b
g[0] = 1*255b
b[0] = 1*255b
r[254] = 0
g[254] = 0
b[254] = 0
tvlct,r,g,b
plot_image,img,scale=[1,1],origin=[-0.5,-0.5],xtitle='p-side [ch]',ytitle='n-side [ch]',max=nmax, min=nmin-1, /sq, color = 254, $
           xrange=xrange, yrange=yrange, _extra=_extra
oplot, [64,64], [0,127], color=1
oplot, [0,127], [64,64], color=1

END


