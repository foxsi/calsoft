FUNCTION FORMATTER_PACKET, FILE, DETECTOR, STOP=STOP, TRIG_TIME = TRIG_TIME, FRAME_TIME = FRAME_TIME, STATUS=STATUS
; FUNCTION FORMATTER_PACKET_B, FILE, DETECTOR, STOP=STOP, LIVETIME=LIVETIME, RATE=RATE, STATUS=STATUS

                                ; reworking by Lindsay June 2012 to
                                ; speed up processing.  As of 6/26,
                                ; this works.  

                                ; Remaining tasks:  Go through code
                                ; again to make sure that all the
                                ; header values (nondata) are being
                                ; captured.  Also further test and
                                ; debug the livetime code.

  bad_events = 0

  ; prepare the type of data structure you want
  data_struct = {foxsi_data, $
                 time:ulonarr(4),  $         ; detector time
                 frame_counter:lonarr(4),  $         ; frame counter
                 start:intarr(4), $         ; start bit, should be 1
                 chip_bit:intarr(4), $      ; was there data in the chip
                 seu:intarr(4), $           ; was there an SEU
                 common_mode:intarr(4), $   ; common mode noise
                 data:intarr(4,64), $ ; strip data
                 ped:intarr(4), $            ; dummy pedestal value
                 packet_error:intarr(4), $   ; number of channels with packet error 
                 cmn_median:fltarr(4), $    ; common mode noise (calculated from data, median)
                 cmn_average:fltarr(4) $   ; common mode noise (calculated from data, average)
                }

    print, 'Reading file ', file
    raw_data = read_binary(file, data_type=12) ; data_dims=[256,nFrames], data_type=12)
    n = n_elements(raw_data)
    nFrames = n/256
    det_time = uintarr(nFrames)
    form_time = uintarr(nFrames)
    raw_data = raw_data[0:(n/256)*256-1]
    ;raw_data = transpose(reform(raw_data,[nFrames,256]))
    raw_data = reform(raw_data,[256,nFrames])

    print, 'Creating data structure.'

    ; make array of structures, one for each event.
    data_struct = replicate(data_struct, nFrames)

    ;for j=0, 3 do data_struct.time[j,*] = ishft(raw_data[1,*],32) + ishft(raw_data[2,*],16) + raw_data[3,*] 
    ;; later, need to replace this with individual detector times.
    
    for j=0, 3 do data_struct.frame_counter[j,*] = ishft(raw_data[4,*],16) + raw_data[5,*]
    for j=0, 3 do data_struct.start[j,*] = 0.
    for j=0, 3 do data_struct.chip_bit[j,*] = 0.
    for j=0, 3 do data_struct.seu[j,*] = 0.

    print, 'Filling in strip data.'

    ; fill in strip data from formatter packet.
    ; initially, all strip values are 0.  only the ones
    ; you change get a value.
    for j=0, 3 do begin
       print, 'ASIC ', j
       for k=0, 2 do begin
          index = 28 + 33*detector + k + 8*j
          strip = reform( ishft(raw_data[index,*],-10) )
;          data_struct.data[j,strip,*] = reform( raw_data[index,*] ) - ishft(strip,10)
          for i=0L, nFrames-1 do data_struct[i].data[j,strip[i]] = reform( raw_data[index,i] ) - ishft(strip[i],10)
       endfor
    endfor

    ; grab the common mode
    for j=0, 3 do data_struct.common_mode[j,*] = raw_data[31 + 33*detector + 8*j,*]

    ; if the common mode is strange, that means it's a bad packet.  throw away the data.
    k0 = where (data_struct.common_mode[0] gt 1023 or data_struct.common_mode[0] lt 1)
    k1 = where (data_struct.common_mode[1] gt 1023 or data_struct.common_mode[1] lt 1)
    k2 = where (data_struct.common_mode[2] gt 1023 or data_struct.common_mode[2] lt 1)
    k3 = where (data_struct.common_mode[3] gt 1023 or data_struct.common_mode[3] lt 1)
    data_struct[k0].data[*,*] = 0
    data_struct[k1].data[*,*] = 0
    data_struct[k2].data[*,*] = 0
    data_struct[k3].data[*,*] = 0
    data_struct[k0].common_mode = 0
    data_struct[k1].common_mode = 0
    data_struct[k2].common_mode = 0
    data_struct[k3].common_mode = 0
    k = [k0, k1, k2, k3]
    k = uniq(k, sort(k))
 ;   data_struct[k].data = 0
 ;   data_struct[k].common_mode = 0
    nK = n_elements(k)

    print, n_elements(k0), n_elements(k1), n_elements(k2), n_elements(k3)
    print, 'Good events: ', nFrames - nK, ' out of ', nFrames

    print, 'Calculating livetime.'

    form_time = raw_data[3,*]
    det_time = raw_data[23 + 33*detector, *]
    for j=0, 3 do data_struct.time[j,*] = raw_data[23 + 33*detector, *]

;           livetime[i-1] = raw_data[23 + 33*detector, i] - raw_data[3,i-1]


;    ; calculate livetime by comparing frame time and detector
;    ; trigger time.  later, need to subtract a specified time for each frame.
;    livetime = det_time[1:nFrames-1] - form_time[0:nFrames-2] 
;    nonzero = where (det_time ne 0)
;    rate = n_elements(nonzero)
;    if rate eq 1 then rate = 0
;    rate = 500.*rate / nFrames

;    ; later (after this function):
;    ; avgtime = mean(livetime)*1.e-7
;    ; print, 0.002*rate/avgtime

	; pull out trigger time and detector frame time
	trig_time = float(reform(det_time))
	frame_time = float(reform(form_time))
	; flag elements from bad packets
	;trig_time[k] = -1
	;frame_time[k] = -1

	; Get the status byte
	status = raw_data[19,*]

    if keyword_set(stop) then stop

    print, 'Finished processing file ', file

    return, data_struct

END

