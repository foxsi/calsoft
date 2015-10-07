;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO DRAW_4SPEC, HIST, XRANGE = XRANGE, YRANGE = YRANGE, REBIN = REBIN, $
	_EXTRA = _EXTRA, CH = CH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;if not keyword_set(xrange) then xrange = [0, 1023]
  ;if not keyword_set(yrange) then yrange = []

 if not keyword_set(rebin) then rebin=1
 if not keyword_set(ch) then ch = 64

; window, xsize = 800, ysize = 600
!p.multi = [0, 2, 2]
  for asic = 0, 3 do begin

xx=hist(*, ch, asic, 0)
yy=hist(*, ch, asic, 1)
plotx=rebin2(xx,rebin)
ploty=rebin2(yy,rebin)

      plot, plotx, ploty, xrange = xrange, _extra = _extra, $
        yrange = yrange, psym = 10, $
        xtitle='Energy [keV]'
  endfor



END


