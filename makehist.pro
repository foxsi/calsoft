;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION MAKEHIST, FILE, $
              SUBTRACT_COMMON = SUBTRACT_COMMON, CMN_AVERAGE = CMN_AVERAGE, $
              CMN_MEDIAN = CMN_MEDIAN, STOP = STOP, gooddata=gooddata, _extra=extra
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;if not keyword_set(savefile) then savefile = 'pedestal.sav'

  ; call preceding function to read in the data file(s).
  ;data = read_data_struct(file, subtract = subtract_common, stop = stop)
  restore,file
  n_evts = n_elements(data)

  print, n_evts, ' total events'

  ; Split data up into ASICs. subtract common mode noise if desired.
  i0 = where(rebin(data.packet_error,1,n_evts) lt 2.5)

  cmn = intarr(n_evts,4)
  hist = fltarr(1124, 64,  4, 2)

  for as=0, 3 do begin
;      if keyword_set(subtract_common) then cmn[*,as] = data[*].common_mode[as] + randomu(seed,n_evts*4+as) - 0.5
      if keyword_set(subtract_common) then cmn[*,as] = data[*].common_mode[as]
      if keyword_set(cmn_average) then cmn[*,as] = data[*].cmn_average[as]
      if keyword_set(cmn_median) then cmn[*,as] = data[*].cmn_median[as] + randomu(seed,n_evts*4+as) - 0.5
  endfor

  ; debugging
  print, 'events for the spectra', n_elements(i0)

  ; Make histograms of data for each channel.

  for as=0, 3 do begin
      for k = 0, 63 do begin
          if i0[0] gt -1 then gooddata = data[i0].data[as, k]-cmn[i0, as] else gooddata = 0
          hist[*, k, as, 0] = findgen(1124)-100       
          hist[*, k, as, 1] = histogram([gooddata], min = -100, max = 1023)

    endfor

  endfor

  ; save data in current directory with chosen name, for easy recall.
  ;save, a0, a1, a2, a3, file = savefile

  window, xsize = 1800, ysize = 1800
  ;x_axis = indgen(1124)-100
 !p.multi = [0, 2, 2]
  mm = max((rebin(hist, 1124, 1, 4, 2))(*,0,*,1))
  plot, (rebin(hist, 1124, 1, 4, 2))(*, 0, 0, 0), (rebin(hist, 1124, 1, 4, 2))(*, 0, 0, 1), xrange = [-100, 800], yrange = [0.01, mm], $
    xtitle = 'ASIC 0 raw counts', psym = 10,/ylog, _extra=extra
  plot, (rebin(hist, 1124, 1, 4, 2))(*, 0, 1, 0), (rebin(hist, 1124, 1, 4, 2))(*, 0, 1, 1), xrange = [-100, 800], yrange = [0.01, mm], $
    xtitle = 'ASIC 1 raw counts', psym = 10,/ylog, _extra=extra
  plot, (rebin(hist, 1124, 1, 4, 2))(*, 0, 2, 0), (rebin(hist, 1124, 1, 4, 2))(*, 0, 2, 1), xrange = [-100, 800], yrange = [0.01, mm], $
    xtitle = 'ASIC 2 raw counts', psym = 10,/ylog, _extra=extra
  plot, (rebin(hist, 1124, 1, 4, 2))(*, 0, 3, 0), (rebin(hist, 1124, 1, 4, 2))(*, 0, 3, 1), xrange = [-100, 800], yrange = [0.01, mm], $
    xtitle = 'ASIC 3 raw counts', psym = 10,/ylog, _extra=extra

                                ; also store a copy of the save file in data storage directory
;  if n_elements(file) eq 1 then save_name = file else save_name = file[0]
;  if keyword_set(subtract_common) then save_name = save_name + '_sub'
;  save_name = save_name + '.sav'
;  save, a0, a1, a2, a3, file = save_name
  
  return, hist
  
END
