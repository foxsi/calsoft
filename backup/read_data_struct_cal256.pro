;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION READ_DATA_STRUCT_CAL256, FILE, SUBTRACT = SUBTRACT, STOP = STOP              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; reads in data from a file array, returns data in structure form.
  ; this function is used by the main processing procedure.

  n_files = n_elements(file)
  restore, 'template_cal.sav'

  bad_events = 0


  ; prepare the type of data structure you want
  data_struct = {foxsi_data, $
                 ;asic:intarr(4), $          ; asic 0-3 (0:1 n-side, 2:3 p-side
                 ;sync:starr(4), $           ; sync word for next frame part
                 time:lonarr(4),  $         ; detector time
                 frame_counter:lonarr(4),  $         ; frame counter
                 start:intarr(4), $         ; start bit, should be 1
                 chip_bit:intarr(4), $      ; was there data in the chip
                 ;analog_trg:0, $    ; was there an analog trigger
                 seu:intarr(4), $           ; was there an SEU
                 ;mask:'0', $        ; channel mask
                 common_mode:intarr(4), $   ; common mode noise
                 data:intarr(4,64), $ ; strip data
                 ped:intarr(4), $            ; dummy pedestal value
                 packet_error:intarr(4), $   ; number of channels with packet error 
                 ;error_flag:0, $     ; 1 if sync or mask is not correct 
                 cmn_median:fltarr(4), $    ; common mode noise (calculated from data, median)
                 cmn_average:fltarr(4) $   ; common mode noise (calculated from data, average)
                 ;stop:0, $          ; stop bit, should be 1
                }

  ; loop through files
    for j = 0, n_files-1 do begin
    print, 'Reading file ', file[j]
    raw_data = read_ascii(file[j], template = template)

    ; make array of structures, one for each event.
    n_evts = n_elements(raw_data.start_bit)
    n_trigs = long(n_evts/4.)

    temp_struct = replicate(data_struct[0], 1)

    ; populate event structure array with data.
    ; this could probably be done more efficiently.

    i=long(0)
    ngood=long(0)
    while i lt n_evts-3 do begin

        if (i mod 4000) eq 0 then print, 'Event ', long(i/4) ,'/', n_trigs       
 

        if raw_data.sync_word[i] + raw_data.sync_word[i+1] + raw_data.sync_word[i+2] + $
           raw_data.sync_word[i+3] eq 'eb90eb91eb92eb93' and $
           raw_data.channel_mask[i] + raw_data.channel_mask[i+1] + $
           raw_data.channel_mask[i+2] + raw_data.channel_mask[i+3] eq $
        '11ffffffffffffffff11ffffffffffffffff11ffffffffffffffff11ffffffffffffffff' then begin


            flag256 = intarr(4, 64)
            hitchnum = 0
            err256 = 0
            for as = 0, 1 do begin  ; first 2 ASICs (n-side)
                temp_struct[0].time[as]          = raw_data.livetime1[i+as]+long(2)^16*raw_data.livetime2[i+as]
                temp_struct[0].frame_counter[as] = raw_data.frame_counter[i+as]
                temp_struct[0].start[as]         = raw_data.start_bit[i+as]
                temp_struct[0].chip_bit[as]      = raw_data.chip_data_bit[i+as]
                temp_struct[0].seu[as]           = raw_data.seu[i+as]
                temp_struct[0].common_mode[as]   = raw_data.common_mode[i+as]
                temp_struct[0].ped[as]           = raw_data.pedestal[i+as]
                temp_struct[0].cmn_median[as]    = median(raw_data.adc[*, i+as])
                temp_struct[0].cmn_average[as]   = getcmn(raw_data.adc[*, i+as])
                temp_struct[0].packet_error[as]  = 0

                for ch = 0, 63 do begin
                    if raw_data.adc[ch, i+as] gt 1023 or raw_data.adc[ch, i+as] lt 0 then begin
                        raw_data.adc[ch, i+as] = 0
                        temp_struct[0].packet_error[as] += 1
                    endif
                    signal = raw_data.adc[ch, i+as] - temp_struct[0].cmn_median[as]
                    temp_struct[0].data[as,ch] = raw_data.adc[ch, i+as]
                endfor
            endfor

            hitchnum = 0
            err256 = 0
            for as = 2, 3 do begin  ; first 2 ASICs (p-side)
                temp_struct[0].time[as]          = raw_data.livetime1[i+as]+long(2)^16*raw_data.livetime2[i+as]
                temp_struct[0].frame_counter[as] = raw_data.frame_counter[i+as]
                temp_struct[0].start[as]         = raw_data.start_bit[i+as]
                temp_struct[0].chip_bit[as]      = raw_data.chip_data_bit[i+as]
                temp_struct[0].seu[as]           = raw_data.seu[i+as]
                temp_struct[0].ped[as]           = raw_data.common_mode[i+as]
                temp_struct[0].common_mode[as]   = raw_data.pedestal[i+as]
                temp_struct[0].cmn_median[as]    = median(raw_data.adc[*, i+as])
                temp_struct[0].cmn_average[as]   = getcmn(raw_data.adc[*, i+as])
                temp_struct[0].packet_error[as]  = 0
                for ch = 0, 63 do begin
                    if raw_data.adc[ch, i+as] gt 1023 or raw_data.adc[ch, i+as] lt 0 then begin
                        raw_data.adc[ch, i+as] = 0
                        temp_struct[0].packet_error[as] += 1
                    endif
                    signal = raw_data.adc[ch, i+as] - temp_struct[0].cmn_median[as]
                    temp_struct[0].data[as,ch] = raw_data.adc[ch, i+as]
                endfor
            endfor
  


            i+=4
            ngood+=1
            data_struct = [data_struct, temp_struct]

        endif else begin
            i+=1
        endelse

    endwhile


  if keyword_set(stop) then stop
  print, 'Finished processing ', file[j]
  print, 'Good events: ',ngood, '/', n_trigs
  
endfor
  
n = n_elements(data_struct)-1
data_struct = data_struct[1:n]

  ; return array of events, one structure element per event.
return, data_struct

END
