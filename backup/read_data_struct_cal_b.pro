;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION READ_DATA_STRUCT_CAL_B, FILE, SUBTRACT = SUBTRACT, STOP = STOP              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; reads in data from a file array, returns data in structure form.
  ; this function is used by the main processing procedure.

  ; modified by Lindsay June 2012 for more efficient way of 
  ; processing structures.

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

    data_struct = replicate(data_struct, n_evts)

    ; populate event structure array with data.

    i=long(0)
    ngood=long(0)
    while i lt n_evts-3 do begin

        if (i mod 4000) eq 0 then print, 'Event ', long(i/4) ,'/', n_trigs       ; status update
 
        ; check that we're syncing properly.
        if raw_data.sync_word[i] + raw_data.sync_word[i+1] + raw_data.sync_word[i+2] + $
           raw_data.sync_word[i+3] ne 'eb90eb91eb92eb93' then continue
;           raw_data.channel_mask[i] + raw_data.channel_mask[i+1] + $
;           raw_data.channel_mask[i+2] + raw_data.channel_mask[i+3] eq $
;        '11ffffffffffffffff11ffffffffffffffff11ffffffffffffffff11ffffffffffffffff' then begin

        flag256 = intarr(4, 64)
        hitchnum = 0
        err256 = 0
        for as = 0, 1 do begin  ; first 2 ASICs (n-side)
           data_struct[i/4].time[as]          = raw_data.livetime1[i+as]+long(2)^16*raw_data.livetime2[i+as]
           data_struct[i/4].frame_counter[as] = raw_data.frame_counter[i+as]
           data_struct[i/4].start[as]         = raw_data.start_bit[i+as]
           data_struct[i/4].chip_bit[as]      = raw_data.chip_data_bit[i+as]
           data_struct[i/4].seu[as]           = raw_data.seu[i+as]
           data_struct[i/4].common_mode[as]   = raw_data.common_mode[i+as]
           data_struct[i/4].ped[as]           = raw_data.pedestal[i+as]
           data_struct[i/4].cmn_median[as]    = median(raw_data.adc[*, i+as])
           data_struct[i/4].cmn_average[as]   = getcmn(raw_data.adc[*, i+as])
           data_struct[i/4].packet_error[as]  = 0

           for ch = 0, 63 do begin
              if raw_data.adc[ch, i+as] gt 1023 or raw_data.adc[ch, i+as] lt 0 then begin
                 raw_data.adc[ch, i+as] = 0
                 data_struct[i/4].packet_error[as] += 1
              endif
              signal = raw_data.adc[ch, i+as] - data_struct[i/4].cmn_median[as]
              if signal gt 65 then begin
                 hitchnum+=1
                 if signal gt 206 and signal lt 306 then begin
                    err256+=1
                    flag256[as, ch]=1
                 endif
              endif
              data_struct[i/4].data[as,ch] = raw_data.adc[ch, i+as]
           endfor
        endfor

        if hitchnum-err256 gt 0 then begin
           for ch = 0, 63 do begin
              for as = 0, 1 do begin
                 data_struct[i/4].data[as,ch] = data_struct[i/4].data[as,ch] $
                                              - flag256[as, ch]*256
              endfor
           endfor
        endif

        hitchnum = 0
        err256 = 0
        for as = 2, 3 do begin  ; first 2 ASICs (p-side)
           data_struct[i/4].time[as]          = raw_data.livetime1[i+as]+long(2)^16*raw_data.livetime2[i+as]
           data_struct[i/4].frame_counter[as] = raw_data.frame_counter[i+as]
           data_struct[i/4].start[as]         = raw_data.start_bit[i+as]
           data_struct[i/4].chip_bit[as]      = raw_data.chip_data_bit[i+as]
           data_struct[i/4].seu[as]           = raw_data.seu[i+as]
           data_struct[i/4].ped[as]           = raw_data.common_mode[i+as]
           data_struct[i/4].common_mode[as]   = raw_data.pedestal[i+as]
           data_struct[i/4].cmn_median[as]    = median(raw_data.adc[*, i+as])
           data_struct[i/4].cmn_average[as]   = getcmn(raw_data.adc[*, i+as])
           data_struct[i/4].packet_error[as]  = 0
           for ch = 0, 63 do begin
              if raw_data.adc[ch, i+as] gt 1023 or raw_data.adc[ch, i+as] lt 0 then begin
                 raw_data.adc[ch, i+as] = 0
                 data_struct[i/4].packet_error[as] += 1
              endif
              signal = raw_data.adc[ch, i+as] - data_struct[i/4].cmn_median[as]
              if signal gt 30 then begin
                 hitchnum+=1
                 if signal gt 241 and signal lt 271 then begin
                    err256+=1
                    flag256[as, ch]=1
                 endif
              endif
              data_struct[i/4].data[as,ch] = raw_data.adc[ch, i+as]
           endfor
        endfor
        if hitchnum-err256 gt 0 then begin
           for ch = 0, 63 do begin
              for as = 2, 3 do begin
                 data_struct[i/4].data[as,ch] = data_struct[i/4].data[as,ch] $
                                              - flag256[as, ch]*256
              endfor
           endfor
        endif

        i+=4
        ngood+=1
;            data_struct = struct_append(data_struct, temp_struct)
;            data_struct = [data_struct, temp_struct]

    endwhile


    if keyword_set(stop) then stop
    print, 'Finished processing ', file[j]
    print, 'Good events: ',ngood, '/', n_trigs
  
 endfor
  
;    n = n_elements(data_struct)-1
;    data_struct = data_struct[1:n]

  ; return array of events, one structure element per event.
    return, data_struct

END
