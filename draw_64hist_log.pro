;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO DRAW_64HIST_LOG, HIST, ASIC, XRANGE = XRANGE, YRANGE = YRANGE, REBIN=REBIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;if not keyword_set(xrange) then xrange = [0, 1023]
  if not keyword_set(yrange) then yrange = [0.5,1000]
  if not keyword_set(rebin) then rebin=1

 window, xsize = 1200, ysize = 800
  ;x_axis = indgen(1124)-100
 !p.multi = [0, 8, 8]
  for ch = 0, 63 do begin
plotx=rebin2(hist(*, ch, asic,0),rebin)
ploty=rebin2(hist(*, ch, asic,1),rebin)
    plot, plotx,ploty, xrange = xrange, yrange = yrange, psym = 10,/ylog
  endfor

END


