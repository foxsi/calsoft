;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO DRAW_64HIST, HIST, ASIC, XRANGE = XRANGE, YRANGE = YRANGE, REBIN=REBIN, NOWINDOW=NOWINDOW, $
  xsize = xsize, ysize = ysize, label_ch=label_ch, leg_chars=leg_chars, sum=sum, saveplot=saveplot, $
  plotname=plotname, _extra=extra
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  default, xsize, 1200
  default, ysize, 600
  default, leg_chars, 1
  default, sum, 0 ; set to one to sum histograns in a list
  default, saveplot, 0
  default, plotname, '64histo.eps'
  
  if typename(hist) EQ 'LIST' THEN sum=1
  if saveplot EQ 1 AND not keyword_set(xsize) THEN xsize = 160
  if saveplot EQ 1 AND not keyword_set(ysize) THEN xsize = 80
  
  ;if not keyword_set(xrange) then xrange = [0, 1023]
  ;if not keyword_set(yrange) then yrange = []
  if not keyword_set(rebin) then rebin=1

  if not keyword_set(nowindow) then window, xsize = xsize, ysize = ysize
  ;x_axis = indgen(1124)-100
  
  if sum EQ 1 then BEGIN
    if typename(hist) NE 'LIST' THEN BEGIN
      print, 'need a list of histograms'
    endif else begin
      histo = hist[0]
      FOR k=1, n_elements(hist)-1 DO BEGIN
        h_temp = hist[k]
        histo[*, *, *, 1] = histo[*, *, *, 1] + h_temp[*, *, *, 1]
      ENDFOR
      hist=histo
    endelse
  endif
  
  IF saveplot EQ 1 THEN BEGIN
    set_plot,'ps'
    device,filename=plotname, /encapsulated, /color, xsize=xsize, ysize=ysize, yoffset=-5
  ENDIF

  !p.multi = [0, 8, 8]
  for ch = 0, 63 do begin
    plotx=rebin2(hist(*, ch, asic,0),rebin)
    ploty=rebin2(hist(*, ch, asic,1),rebin)
    plot, plotx,ploty, xrange = xrange, yrange = yrange, psym = 10, _extra=extra
    IF keyword_set(label_ch) THEN al_legend, strsplit(string(ch),/extract), right_legend=1, box=0, chars=leg_chars, charth=th
  endfor
  !p.multi = 0
  
  IF saveplot EQ 1 THEN BEGIN
    device,/close
    set_plot,'win'
    print, plotname+' has been written'
  ENDIF
  
END


