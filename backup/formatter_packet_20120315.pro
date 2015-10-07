FUNCTION FORMATTER_PACKET, FILE, DETECTOR, STOP=STOP, LIVETIME=LIVETIME, RATE=RATE

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

    temp_struct = replicate(data_struct[0], 1)

    for i=0, nFrames-1 do begin

        if (i mod 1000) eq 0 then print, 'Event ', i, ' of ', nFrames

        for j=0, 3 do temp_struct[0].time[j] = ishft(raw_data[1,i],32) + ishft(raw_data[2,i],16) + raw_data[3,i] ; later, need to replace this with individual detector times.
        for j=0, 3 do temp_struct[0].frame_counter[j] = ishft(raw_data[4,i],16) + raw_data[5,i]
        for j=0, 3 do temp_struct[0].start[j] = 0.
        for j=0, 3 do temp_struct[0].chip_bit[j] = 0.
        for j=0, 3 do temp_struct[0].seu[j] = 0.

        ; initially, set all strip values to 0.
        for j=0, 3 do begin
            for k=0,63 do temp_struct[0].data[j,k] = 0.
        endfor

        ; then fill in values from formatter packet
        for j=0, 3 do begin
            for k=0, 2 do begin
                index = 28 + 33*detector + k + 8*j
                strip = ishft(raw_data[index,i],-10)
                temp_struct[0].data[j,strip] = raw_data[index,i] - ishft(strip,10)
            endfor
        endfor

        ; grab the common mode
        for j=0, 3 do temp_struct[0].common_mode[j] = raw_data[31 + 33*detector + 8*j,i]

        data_struct = [data_struct, temp_struct]

        form_time[i] = raw_data[3,i]
        det_time[i] = raw_data[23 + 33*detector, i]
;           livetime[i-1] = raw_data[23 + 33*detector, i] - raw_data[3,i-1]

    endfor

    livetime = det_time[1:nFrames-1] - form_time[0:nFrames-2] ; calculate livetime by comparing frame time and detector trigger time.  later, need to subtract a specified time for each frame.
    nonzero = where (det_time ne 0)
    rate = n_elements(nonzero)
    if rate eq 1 then rate = 0
    rate = 500.*rate / nFrames

    ; later (after this function):
    ; avgtime = mean(livetime)*1.e-7
    ; print, 0.002*rate/avgtime

    if keyword_set(stop) then stop

    n = n_elements(data_struct)-1
    data_struct = data_struct[1:n]

    return, data_struct

END

