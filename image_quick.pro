;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION IMAGE_QUICK, FILE, $
              CHRANGE=CHRANGE, BADCH=BADCH, NMAX = NMAX, SUBTRACT_COMMON = SUBTRACT_COMMON, $
              CMN_AVERAGE = CMN_AVERAGE, CMN_MEDIAN = CMN_MEDIAN, STOP = STOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



   if not keyword_set(chrange) then chrange=[20,1000]
  if not keyword_set(badch) then badch=intarr(4,64)


  ; call preceding function to read in the data file(s).
  ;data = read_data_struct(file, subtract = subtract_common, stop = stop)

  restore,file


  n_evts = n_elements(data)
  print, n_evts, ' total events'

  cmn = fltarr(n_evts, 4)

  for as=0, 3 do begin
      if keyword_set(subtract_common) then cmn[*,as] = data[*].common_mode[as] + randomu(seed,n_evts*4+as) - 0.5
      if keyword_set(cmn_average) then cmn[*,as] = data[*].cmn_average[as]
      if keyword_set(cmn_median) then cmn[*,as] = data[*].cmn_median[as] + randomu(seed,n_evts*4+as) - 0.5
  endfor


  img=fltarr(128, 128)

;n_evts=100
    if keyword_set(nmax) then n_evts = nmax
    ngood=long(0)

    hitch=intarr(4)
    for evt = long(0), n_evts-1 do begin
        
        if (evt mod 1000) eq 0 then print, 'Event  ', evt, ' / ', n_evts

        
        if total(data[evt].packet_error) lt 10 then begin

            for as = 0, 3 do begin
                temp=data[evt].data[as,*]*(1-badch[as,*])
                hitch[as]=(where(temp eq max(temp)))[0]
            endfor

            if data[evt].data[0,hitch[0]]-cmn[evt,0] gt data[evt].data[1,hitch[1]]-cmn[evt,1] then begin
                yy=hitch[0]
            endif else begin
                yy=hitch[1]+64
            endelse

            if data[evt].data[2,hitch[2]]-cmn[evt,2] gt data[evt].data[3,hitch[3]]-cmn[evt,3] then begin
                xx=63-hitch[2]
                hitasic=2
                hhitch=hitch[2]
            endif else begin
                xx=127-hitch[3]
                hitasic=3
                hhitch=hitch[3]
            endelse

            chdep=data[evt].data[hitasic,hhitch]-cmn[evt,hitasic]
            if chdep ge chrange[0] and chdep le chrange[1]  then img[xx,yy] += 1

            
        endif
    endfor





  
  return, img
  
END
