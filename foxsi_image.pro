;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION foxsi_IMAGE, FILE, PEAKSFILE = PEAKSFILE, BINWIDTH = BINWIDTH, THRP = THRP, $
              ERANGE=ERANGE, BADCH=BADCH, NMAX = NMAX, SUBTRACT_COMMON = SUBTRACT_COMMON, $
              CMN_AVERAGE = CMN_AVERAGE, CMN_MEDIAN = CMN_MEDIAN, STOP = STOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;if not keyword_set(savefile) then savefile = 'pedestal.sav'
  if not keyword_set(peaksfile) then peaksfile = 'peaks.sav'
  if not keyword_set(erange) then erange=[4.0,100]
  if not keyword_set(thrp) then thrp=4.0
  if not keyword_set(badch) then badch=intarr(4,64)


  ; call preceding function to read in the data file(s).
  ;data = read_data_struct(file, subtract = subtract_common, stop = stop)

  restore,file
  restore,peaksfile

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

    hitch=0
    for evt = long(0), n_evts-1 do begin
        
        if (evt mod 1000) eq 0 then print, 'Event  ', evt, ' / ', n_evts

        
        if total(data[evt].packet_error) lt 10 then begin
            hitchnump=0
            edepold=0
            for as = 0, 1 do begin ; n-side
                for ch = 0, 63 do begin
                    edep = spline(peaks[*,ch,as,0],peaks[*,ch,as,1],data[evt].data[as,ch]-cmn[evt,as])                    
                    if badch[as,ch] eq 0 and edep gt edepold then begin
                        hitchn=ch
                        hitasicn=as
                        edepold=edep
                    endif
                endfor
            endfor
            for as = 2, 3 do begin ; p-side
                for ch = 0, 63 do begin
                    edep = spline(peaks[*,ch,as,0],peaks[*,ch,as,1],data[evt].data[as,ch]-cmn[evt,as])                    
                    if badch[as,ch] eq 0 and edep gt thrp then begin
                        hitchnump+=1
                        hitchp=ch
                        hitasicp=as
                    endif
                endfor
            endfor

            ;print, hitchnump, hitchnumn

            if hitchnump eq 1 then begin
                ngood += 1
                edepldp=spline(peaks[*,hitchp,hitasicp,0],peaks[*,hitchp,hitasicp,1],$
                               data[evt].data[hitasicp,hitchp]-cmn[evt,hitasicp]-0.5)
                edepudp=spline(peaks[*,hitchp,hitasicp,0],peaks[*,hitchp,hitasicp,1],$
                               data[evt].data[hitasicp,hitchp]-cmn[evt,hitasicp]+0.5)
                addcount=1.0
                if edepldp lt erange[0] then addcount -= (erange[0]-edepldp)/(edepudp-edepldp)
                if edepudp gt erange[1] then addcount -= (edepudp-erange[1])/(edepudp-edepldp)

                xx = -hitchp+(hitasicp-1)*64         ;pside
                yy = hitchn+hitasicn*64              ;nside
                if addcount gt 0 then img[xx,yy] += addcount
 
            endif
            
        endif
    endfor

    print, 'p-side 1hit events: ', ngood, '/', n_evts




  
  return, img
  
END
