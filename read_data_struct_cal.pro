;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION READ_DATA_STRUCT_CAL, FILE, SUBTRACT = SUBTRACT, STOP = STOP              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; reads in data from a file array, returns data in structure form.
  ; this function is used by the main processing procedure.

  ; modified by Lindsay June 2012 for more efficient way of 
  ; processing structures.  In this version, testing out a way
  ; of ditching the big loop completely.  As of June 27 2012,
  ; this looks like it works well.

  ; notes: file argument should be a single file only.

  if n_elements(file) gt 1 then begin
     print, 'Single file required.'
     return, 0
  endif

  restore, 'C:\Users\SMusset\Documents\GitHub\calsoft\template_cal.sav'

  ; prepare the type of data structure you want
  data_struct = {foxsi_data, $
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
                }

    print, 'Reading file ', file
    raw_data = read_ascii(file, template = template)

    ; get rid of any excess header
    bad = where(raw_data.sync_word ne 'eb90' and raw_data.sync_word ne 'eb91' and raw_data.sync_word ne 'eb92' and raw_data.sync_word ne 'eb93')
    n_bad = n_elements(bad)
    if bad[0] gt -1 then n_bad = bad[n_bad-1]+1
    while raw_data.sync_word[n_bad] ne 'eb90' do n_bad++

    ; make array of structures, one for each event.
    n_evts = n_elements(raw_data.start_bit)/4
    data_struct = replicate(data_struct, n_evts)

    ; populate event structure array with data.

;    i = findgen(n_evts)  ; to index the data structre
    j = transpose(findgen(4,n_evts))+n_bad  ; to index the raw data, different rows for different ASICs.

    ; Check sync. Flag bad events.
    good_evts = where( raw_data.sync_word[j[*,0]] + raw_data.sync_word[j[*,1]] + raw_data.sync_word[j[*,2]] + $
                       raw_data.sync_word[j[*,3]] eq 'eb90eb91eb92eb93')

    ; Note: you could use the channel mask as an additional check if desired.
    ;           raw_data.channel_mask[i] + raw_data.channel_mask[i+1] + $
    ;           raw_data.channel_mask[i+2] + raw_data.channel_mask[i+3] neq $
    ;        '11ffffffffffffffff11ffffffffffffffff11ffffffffffffffff11ffffffffffffffff'

    for as = 0, 3 do begin      ; Gather frame info ASIC by ASIC.

       print, 'Processing ASIC ', as

       data_struct.time[as]          = raw_data.livetime1[j[*,as]]+long(2)^16*raw_data.livetime2[j[*,as]]
       data_struct.frame_counter[as] = raw_data.frame_counter[j[*,as]]
       data_struct.start[as]         = raw_data.start_bit[j[*,as]]
       data_struct.chip_bit[as]      = raw_data.chip_data_bit[j[*,as]]
       data_struct.seu[as]           = raw_data.seu[j[*,as]]
       data_struct.common_mode[as]   = raw_data.common_mode[j[*,as]]
       data_struct.ped[as]           = raw_data.pedestal[j[*,as]]
       data_struct.cmn_median[as]    = median(raw_data.adc[*, j[*,as]],dim=1)
       data_struct.cmn_average[as]   = getcmn(raw_data.adc[*, j[*,as]])
       data_struct.packet_error[as]  = 0

       for ch = 0, 63 do begin  ; here is the actual strip data.

          ; save data values
          data_struct.data[as,ch] = reform(raw_data.adc[ch, j[*,as]])
          ; check data quality, flag bad values.
	  ;if ch ne 4 then begin
          k = where( data_struct.data[as,ch] gt 1023 or data_struct.data[as,ch] lt 0 )
		  if k gt 0 then begin
            data_struct[k].data[as,ch] = -1  ; a visible wrong value.
            data_struct[k].packet_error = 1
		  endif
	;endif

       endfor

       ; fix +256 error.  Subtract 256 from channels where 
       ; another hit is found.  Since the hit could be on
       ; the other ASIC, this has to be done for two ASICs
       ; at once.

       if as eq 1 or as eq 3 then begin  ; once for n-side and once for p-side

          dataA = reform(data_struct.data[as-1,*]) ; all data for first ASIC, all events
          dataB = reform(data_struct.data[as,*])   ; all data for second ASIC, all events
          ; make array of common mode values with same dim as data
          cmnA = data_struct.cmn_median[as-1]
          cmnB = data_struct.cmn_median[as]
          cmnA = transpose(cmreplicate(cmnA, 64))
          cmnB = transpose(cmreplicate(cmnB, 64))
          ; subtract these common mode values
          subA = dataA - cmnA
          subB = dataB - cmnB
          ; define hit criteria differently for each side.
          if as eq 1 then begin
             hitsA = subA gt 60
             hitsB = subB gt 60
             flag256A = subA gt 206 and subA lt 306
             flag256B = subB gt 206 and subB lt 306
          endif else begin
             hitsA = subA gt 30
             hitsB = subB gt 30
             flag256A = subA gt 241 and subA lt 271
             flag256B = subB gt 241 and subB lt 271
          endelse
          ; add up number of hits per event
          hits_totA = total(hitsA,1)
          hits_totB = total(hitsB,1)
          ; add up # of +256 possibilities per evt
          flag256_totA = total(flag256A,1)
          flag256_totB = total(flag256B,1)
          ; if #hits > #256hits then the +256 hit is an error
          check = byte(transpose( cmreplicate( hits_totA + hits_totB - flag256_totA - flag256_totB, 64 ) ))
          ; subtract 256 from values that are in error.
          dataA = dataA - check*flag256A*256
          dataB = dataB - check*flag256B*256
          ; replace data into the structure.
          data_struct.data[as-1,*] = transpose( cmreplicate( transpose(dataA),1) )
          data_struct.data[as,*] = transpose( cmreplicate( transpose(dataB),1) )

       endif

    endfor

    ; eliminate the bad events.
    data_struct = data_struct[good_evts]

   if keyword_set(stop) then stop

    print, 'Finished processing ', file
    print, 'Good events: ', n_elements(good_evts), '/', n_evts
  
  ; return array of events, one structure element per event.
    return, data_struct

END
