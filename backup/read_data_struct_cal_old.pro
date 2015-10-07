;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION READ_DATA_STRUCT_CAL, FILE, SUBTRACT = SUBTRACT, STOP = STOP              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; reads in data from a file array, returns data in structure form.
  ; this function is used by the main processing procedure.

  n_files = n_elements(file)
  restore, 'template_cal.sav'

  bad_events = 0
  ngood = [0, 0, 0, 0]

  ; prepare the type of data structure you want
  data_struct = {foxsi_data, $
                 asic:0, $          ; asic 0-3 (0:1 n-side, 2:3 p-side
                 sync:'0', $           ; sync word for next frame part
                 time:0,  $         ; detector time
                 start:0, $         ; start bit, should be 1
                 chip_bit:0, $      ; was there data in the chip
                 analog_trg:0, $    ; was there an analog trigger
                 seu:0, $           ; was there an SEU
                 mask:'0', $        ; channel mask
                 common_mode:0, $   ; common mode noise
                 data:intarr(64), $ ; strip data
                 ped:0, $            ; dummy pedestal value
                 packet_error:0, $   ; number of channels with packet error 
                 error_flag:0, $     ; 1 if sync or mask is not correct 
                 cmn_median:0., $    ; common mode noise (calculated from data, median)
                 cmn_average:0. $   ; common mode noise (calculated from data, average)
;                 stop:0, $          ; stop bit, should be 1
                }

  ; loop through files
  for j = 0, n_files-1 do begin

    print, 'Reading file ', file[j]
    raw_data = read_ascii(file[j], template = template)

    ; to do: need a safety clause in case no data is found

    ; make array of structures, one for each event.
    n_evts = n_elements(raw_data.start_bit)

    temp_struct = replicate(data_struct[0], n_evts)

    ; populate event structure array with data.
    ; this could probably be done more efficiently.

    for i = long(0), n_evts-1 do begin
      if (i mod 1000) eq 0 then print, 'Event ', i          

      ;temp_struct[i].packet_error = 0
      ;temp_struct[i].error_flag = 0

      ;temp_struct[i].asic = i mod 4
      temp_struct[i].sync       = raw_data.sync_word[i]
      temp_struct[i].time       = raw_data.time[i]
      temp_struct[i].start      = raw_data.start_bit[i]
      temp_struct[i].chip_bit   = raw_data.chip_data_bit[i]
      temp_struct[i].analog_trg = raw_data.analog_trigger[i]
      temp_struct[i].seu        = raw_data.seu[i]
      temp_struct[i].mask       = raw_data.channel_mask[i]
      temp_struct[i].common_mode= raw_data.common_mode[i]

      for ch = 0, 63 do begin
        temp_struct[i].data[ch] = raw_data.adc[ch, i]
        if temp_struct[i].data[ch] gt 1023 or temp_struct[i].data[ch] lt 0 then begin
          temp_struct[i].data[ch] = 0
          temp_struct[i].packet_error += 1
        endif
      endfor

      temp_struct[i].ped        = raw_data.pedestal[i]
;      temp_struct[i].stop       = raw_data.stop_bit[i]

      temp_struct[i].cmn_median= median(temp_struct[i].data)
      temp_struct[i].cmn_average= getcmn(temp_struct[i].data)

;      if (i mod 1000) eq 0 then print, 'Channel mask ', temp_struct[i].mask

      ; subtract common mode noise.
      ; common mode is computed from data; alternative is to 
      ; use the common mode value as determined by ASIC.
      if keyword_set(subtract) then begin
        common_mode = median(temp_struct[i].data)
        temp_struct[i].data = temp_struct[i].data - common_mode
      endif

      if temp_struct[i].mask ne '11ffffffffffffffff' then temp_struct[i].error_flag = 1

  endfor

  i=long(0)
while i lt n_evts-3 do begin
  if temp_struct[i].sync eq 'eb90' then begin
      if temp_struct[i+1].sync eq 'eb90' then begin
          temp_struct[i].asic=5
          i+=1
      endif else begin
          if temp_struct[i+2].sync eq 'eb90' then begin
              temp_struct[i].asic=5
              temp_struct[i+1].asic=5
              i+=2
          endif else begin
              if temp_struct[i+3].sync eq 'eb90' then begin
                  temp_struct[i].asic=5
                  temp_struct[i+1].asic=5
                  temp_struct[i+2].asic=5
                  i+=3
              endif else begin
                  temp_struct[i].asic=0
                  temp_struct[i+1].asic=1
                  temp_struct[i+2].asic=2
                  temp_struct[i+3].asic=3
                  i+=4
              endelse
          endelse
      endelse
  endif else begin
      temp_struct[i].asic=5
      i+=1
  endelse
endwhile
  
  for i = long(0), n_evts-1 do begin
      if (temp_struct[i].asic eq 5) or $
        (temp_struct[i].asic gt 0 and temp_struct[i].asic lt 4 and temp_struct[i].sync ne 'eb91') then $
        temp_struct[i].error_flag = 1
      if temp_struct[i].asic lt 4 then ngood[temp_struct[i].asic] += 1-temp_struct[i].error_flag
  endfor

    ;
    ; Here, bad frames of data are removed. This section looks for 
    ; certain markers that should be present in a consistent frame
    ; and eliminates that frame if the markers are not found.
    ; Many other markers could be used here too.    ;
    ;
    ;good0 = where(temp_struct.mask eq '1ffffff ffffff ffffff ffffff' and $
    ;              temp_struct.sync eq 'EB90' and temp_struct.asic eq 0)
    ;good1 = where(temp_struct.mask eq '3ffffff ffffff ffffff ffffff' and $
    ;              temp_struct.sync eq 'EB91' and temp_struct.asic eq 1)
    ;good2 = where(temp_struct.mask eq '3ffffff ffffff ffffff ffffff' and $
    ;              temp_struct.sync eq 'EB91' and temp_struct.asic eq 2)
    ;good3 = where(temp_struct.mask eq '3ffffff ffffff ffffff ffffff' and $
    ;              temp_struct.sync eq 'EB91' and temp_struct.asic eq 3)

    ;bad3 = where( temp_struct[good3].data gt 1024 or temp_struct[good3].data lt 0 )
    ;temp_struct[good3].data[bad3] = 0

                                ;good_events = [good0, good1, good2, good3]

  print, 'Good events: '
  print, '  asic0: ', ngood[0]
  print, '  asic1: ', ngood[1]
  print, '  asic2: ', ngood[2]
  print, '  asic3: ', ngood[3]

  data_struct = [data_struct, temp_struct]

  if keyword_set(stop) then stop

  print, 'Finished processing ', file[j]
  
endfor
  
n = n_elements(data_struct)-1
data_struct = data_struct[1:n]

  ; return array of events, one structure element per event.
return, data_struct

END
