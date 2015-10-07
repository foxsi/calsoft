;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COUNTRATE_FE_FUNC, FILE, $
              SUBTRACT_COMMON = SUBTRACT_COMMON, CMN_AVERAGE = CMN_AVERAGE, $
              CMN_MEDIAN = CMN_MEDIAN, BADCH=BADCH, STOP = STOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  restore,file
  restore,'peaks.sav'

  n_evts = n_elements(data)

  cmn = fltarr(n_evts, 4)

  for as=0, 3 do begin
cmn[*,as] = data[*].cmn_median[as] + randomu(seed,n_evts*4+as) - 0.5
  endfor

    hitch=0
    counts=long(0)
    livetime=double(0)
    edepp=float(0)

    for evt = long(0), n_evts-1 do begin
        
        ;if (evt mod 1000) eq 0 then print, 'Event  ', evt, ' / ', n_evts
        hitchnump=0
        hitchnumn=0
        
        if total(data[evt].packet_error) lt 10 and min(data[evt].time[*]) eq max(data[evt].time[*]) then begin
            hitchnump=0


            for as = 2, 3 do begin ; p-side
                for ch = 0, 63 do begin
                    edep = spline(peaks[*,ch,as,0],peaks[*,ch,as,1],data[evt].data[as,ch]-cmn[evt,as])                    
                    if badch[as,ch] eq 0 and edep gt 3 then begin
;                    if edep gt 3 then begin
                        edepp=edep
                        hitchnump+=1
                        hitchp=ch
                        hitasicp=as
                    endif
                endfor
            endfor

;            if hitchnump eq 1 then print,hitchnump, edepp

                livetime+=min(data[evt].time[*])

            if hitchnump eq 1 and edepp gt 4 and edepp lt 8 then begin

                counts+=1
 
            endif
            
        endif
    endfor

  ;print,livetime,counts
  ;print, counts/(livetime/1.0e6),' counts/s', counts, ' events'
  rate=[counts/(livetime/1.0e6),sqrt(counts)/(livetime/1.0e6)]

  return, rate
  
END
