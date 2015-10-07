;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION MAKEHIST, FILE, $
              SUBTRACT_COMMON = SUBTRACT_COMMON, CMN_AVERAGE = CMN_AVERAGE, $
              CMN_MEDIAN = CMN_MEDIAN, STOP = STOP, PED=PED
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
  i0 = where(data.asic eq 0 and data.error_flag eq 0); and data.packet_error eq 0)
  i1 = where(data.asic eq 1 and data.error_flag eq 0); and data.packet_error eq 0)
  i2 = where(data.asic eq 2 and data.error_flag eq 0); and data.packet_error eq 0)
  i3 = where(data.asic eq 3 and data.error_flag eq 0); and data.packet_error eq 0)


  ;if keyword_set(subtract_common) then begin
  ;  asic0 = data[i0].data - data[i0].common_mode
   ; asic1 = data[i1].data - data[i1].common_mode
    ;asic2 = data[i2].data - data[i2].common_mode
    ;asic3 = data[i3].data - data[i3].common_mode
  ;endif else begin


  cmn = intarr(n_evts)
  hist = fltarr(1124, 64,  4, 2)

  if keyword_set(subtract_common) then cmn = data.common_mode + randomu(seed,n_evts) - 0.5
  if keyword_set(cmn_average) then cmn = data.cmn_average
  if keyword_set(cmn_median) then cmn = data.cmn_median + randomu(seed,n_evts) - 0.5
  if keyword_set(ped) then cmn = data.ped + randomu(seed,n_evts) - 0.5

  ; debugging
  print, n_elements(i0), n_elements(i1), n_elements(i2), n_elements(i3)

  ; Make histograms of data for each channel.
  for k = 0, 63 do begin

    if i0[0] gt -1 then asic0 = data[i0].data[k]-cmn[i0] else asic0 = 0
    if i1[0] gt -1 then asic1 = data[i1].data[k]-cmn[i1] else asic1 = 0
    if i2[0] gt -1 then asic2 = data[i2].data[k]-cmn[i2] else asic2 = 0
    if i3[0] gt -1 then asic3 = data[i3].data[k]-cmn[i3] else asic3 = 0

    hist[*, k, 0, 1] = histogram([asic0], min = -100, max = 1023)
    hist[*, k, 1, 1] = histogram([asic1], min = -100, max = 1023)
    hist[*, k, 2, 1] = histogram([asic2], min = -100, max = 1023)
;    if n_elements(asic3) gt 1 then $
    hist[*, k, 3, 1] = histogram([asic3], min = -100, max = 1023)

    for l=0, 3 do begin
        hist[*, k, l, 0] = findgen(1124)-100       
    endfor

  endfor

  ; save data in current directory with chosen name, for easy recall.
  ;save, a0, a1, a2, a3, file = savefile

  window, xsize = 800, ysize = 800
  ;x_axis = indgen(1124)-100
 !p.multi = [0, 2, 2]
  mm = max((rebin(hist, 1124, 1, 4, 2))(*,0,*,1))
  plot, (rebin(hist, 1124, 1, 4, 2))(*, 0, 0, 0), (rebin(hist, 1124, 1, 4, 2))(*, 0, 0, 1), xrange = [-100, 800], yrange = [0.01, mm], $
    xtitle = 'ASIC 0 raw counts', psym = 10,/ylog
  plot, (rebin(hist, 1124, 1, 4, 2))(*, 0, 1, 0), (rebin(hist, 1124, 1, 4, 2))(*, 0, 1, 1), xrange = [-100, 800], yrange = [0.01, mm], $
    xtitle = 'ASIC 1 raw counts', psym = 10,/ylog
  plot, (rebin(hist, 1124, 1, 4, 2))(*, 0, 2, 0), (rebin(hist, 1124, 1, 4, 2))(*, 0, 2, 1), xrange = [-100, 800], yrange = [0.01, mm], $
    xtitle = 'ASIC 2 raw counts', psym = 10,/ylog
  plot, (rebin(hist, 1124, 1, 4, 2))(*, 0, 3, 0), (rebin(hist, 1124, 1, 4, 2))(*, 0, 3, 1), xrange = [-100, 800], yrange = [0.01, mm], $
    xtitle = 'ASIC 3 raw counts', psym = 10,/ylog

                                ; also store a copy of the save file in data storage directory
;  if n_elements(file) eq 1 then save_name = file else save_name = file[0]
;  if keyword_set(subtract_common) then save_name = save_name + '_sub'
;  save_name = save_name + '.sav'
;  save, a0, a1, a2, a3, file = save_name
  
  return, hist
  
END
