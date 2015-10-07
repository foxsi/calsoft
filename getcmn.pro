;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION GETCMN, DATA             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  MaxCMNRMS = 3.0
  cmn = 0.0
  
  rms = 1000.0
  
  for it = 0, 1 do begin
    thr = MaxCMNRMS * rms
    sum = 0.0
    sumev = 0.0
    sumsq = 0.0
    max = -5000.0
    max2 = -5000.0
    min = 5000.0
    min2 = 5000.0

    for ch = 0, (size(data))[1]-1 do begin

      ph = data[ch]
      ;;;print, ph, cmn, abs(ph-cmn), thr
                                ; use only reasonable ones.
      if abs(ph-cmn) lt thr then begin

        sumev += 1
        sum += ph
        sumsq += ph*ph         ; register two larget and smallest pulse heights
        if ph gt max2 then begin
          if ph gt max then begin
            max2 = max          
            max = ph            
          endif else max2 = ph
        endif
        if  ph lt min2 then begin
          if  ph lt min then begin
            min2 = min
            min = ph
          endif else min2 = ph
        endif
      endif                     ; good channel
    endfor                      ; channel loop

                                ; calculate mean and RMS
    sumev -= 4
    if sumev gt 10 then begin
      sum -= (max+max2+min+min2)
      sumsq -= (max*max+max2*max2+min*min+min2*min2)
      cmn = sum / sumev
      rms = sqrt( sumsq/sumev - cmn*cmn )
    endif
  endfor                        ; iteration loop
  
  return, cmn
  
END
