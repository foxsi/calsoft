;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO DRAW_4HIST, HIST, XRANGE = XRANGE, YRANGE = YRANGE, REBIN = REBIN, $
NOWINDOW=NOWINDOW, YLOG=YLOG, BACKGROUND=BACKGROUND, COLOR=COLOR,  xsize=xsize, ysize=ysize, $
_EXTRA=_EXTRA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  default, xsize, 1000
  default, ysize, 1000

  ;if not keyword_set(xrange) then xrange = [0, 1023]
  ;if not keyword_set(yrange) then yrange = []

 if not keyword_set(rebin) then rebin=1
; if not keyword_set(background) then background = 0
; if not keyword_set(color) then color = 255

if not keyword_set(nowindow) then window, xsize = xsize, ysize = ysize
!p.multi = [0, 2, 2]
  for asic = 0, 3 do begin

xx=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 0)
yy=(rebin(hist, 1124, 1, 4, 2))(*, 0, asic, 1)
plotx=rebin2(xx,rebin)
ploty=rebin2(yy,rebin)
      
      plot, plotx, ploty, xrange = xrange, $
        yrange = yrange, psym = 10, $
        xtitle = 'ADC', $
        ytitle = 'ASIC '+strtrim(asic,2)+' histogram', $
        ylog = ylog, _extra=_extra;, $
  ;      background = background, color = color
  endfor



END


