;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO DRAW_HIST_LOG, HIST, ASIC, CH, XRANGE = XRANGE, YRANGE = YRANGE, REBIN = REBIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;if not keyword_set(xrange) then xrange = [0, 1023]
  if not keyword_set(rebin) then rebin=1

plotx=rebin2(hist(*, ch, asic,0),rebin))
ploty=rebin2(hist(*, ch, asic,1),rebin))

 window, xsize = 800, ysize = 600
!p.multi=[0,1,1]
  ;x_axis = indgen(1124)-100

  plot, plotx, ploty, xrange = xrange, yrange = yrange, psym=10, /ylog

END


