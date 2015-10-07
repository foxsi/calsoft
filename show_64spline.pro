;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO SHOW_64SPLINE, PEAKS, ASIC, XRANGE = XRANGE, YRANGE = YRANGE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  if not keyword_set(xrange) then xrange = [0, 1024]
  if not keyword_set(yrange) then yrange = [0,100]

 window, xsize = 1200, ysize = 800
  x_axis = findgen(1000)/1000.*xrange[1]

 !p.multi = [0, 8, 8]
  for ch = 0, 63 do begin
      ploty=spline(peaks[*, ch, asic,0], peaks[*, ch, asic, 1], x_axis)
    plot, x_axis,ploty, xrange = xrange, yrange = yrange, psym = 10
    print, asic, ch, spline(peaks[*, ch, asic,0], peaks[*, ch, asic, 1], 15)/15.
  endfor

END


