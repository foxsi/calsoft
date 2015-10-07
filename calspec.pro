;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION CALSPEC, FILE, PEAKSFILE = PEAKSFILE, THRP = THRP, THRN = THRN , BINWIDTH = BINWIDTH, $
              NBIN = NBIN, BADCH=BADCH, NMAX = NMAX, SUBTRACT_COMMON = SUBTRACT_COMMON, $
              CMN_AVERAGE = CMN_AVERAGE, CMN_MEDIAN = CMN_MEDIAN, STOP = STOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;if not keyword_set(savefile) then savefile = 'pedestal.sav'
  if not keyword_set(peaksfile) then peaksfile = 'peaks.sav'
  if not keyword_set(thrp) then thrp=4.0
  if not keyword_set(thrn) then thrn=5.0
  if not keyword_set(binwidth) then binwidth=0.1
  if not keyword_set(nbin) then nbin =1000
  if not keyword_set(badch) then badch=intarr(4,64)


  ; call preceding function to read in the data file(s).
  ;data = read_data_struct(file, subtract = subtract_common, stop = stop)

  restore,file
  restore,peaksfile

  n_evts = n_elements(data)
  print, n_evts, ' total events'

  cmn = fltarr(n_evts, 4)
  spec = fltarr(nbin, 65, 4, 2)

  for as=0, 3 do begin
      if keyword_set(subtract_common) then cmn[*,as] = data[*].common_mode[as] + randomu(seed,n_evts*4+as) - 0.5
      if keyword_set(cmn_average) then cmn[*,as] = data[*].cmn_average[as]
      if keyword_set(cmn_median) then cmn[*,as] = data[*].cmn_median[as] + randomu(seed,n_evts*4+as) - 0.5
  endfor



   for as=0, 3 do begin
        for ch =0, 64 do begin
            spec[*, ch, as, 0] = (findgen(nbin)+0.5)*binwidth   
        endfor
    endfor

;n_evts=100
    if keyword_set(nmax) then n_evts = nmax
    ngood=long(0)

    hitch=0
    for evt = long(0), n_evts-1 do begin
        
        if (evt mod 1000) eq 0 then print, 'Event  ', evt, ' / ', n_evts
        hitchnump=0
        hitchnumn=0
        
        if total(data[evt].packet_error) lt 10 then begin
            hitchnump=0
            hitchnumn=0
            for as = 0, 1 do begin ; n-side
                for ch = 0, 63 do begin
                    edep = spline(peaks[*,ch,as,0],peaks[*,ch,as,1],data[evt].data[as,ch]-cmn[evt,as])                    
                    if badch[as,ch] eq 0 and edep gt thrn then begin
                        hitchnumn+=1
                        hitchn=ch
                        hitasicn=as
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

            if hitchnump eq 1 and hitchnumn eq 1 then begin
                ngood += 1
                edepldp=spline(peaks[*,hitchp,hitasicp,0],peaks[*,hitchp,hitasicp,1],$
                               data[evt].data[hitasicp,hitchp]-cmn[evt,hitasicp]-0.5)
                edepudp=spline(peaks[*,hitchp,hitasicp,0],peaks[*,hitchp,hitasicp,1],$
                               data[evt].data[hitasicp,hitchp]-cmn[evt,hitasicp]+0.5)
                addadc=(((findgen(100)+0.5)/100.*(edepudp-edepldp)+edepldp)/binwidth)<(nbin-1)>0
                for l=0, 99 do begin
                    spec(addadc[l],hitchp,hitasicp,1)+=1/100./(edepudp-edepldp)
                    spec(addadc[l],64,hitasicp,1)+=1/100./(edepudp-edepldp)
                endfor

                edepldn=spline(peaks[*,hitchn,hitasicn,0],peaks[*,hitchn,hitasicn,1],$
                               data[evt].data[hitasicn,hitchn]-cmn[evt,hitasicn]-0.5)
                edepudn=spline(peaks[*,hitchn,hitasicn,0],peaks[*,hitchn,hitasicn,1],$
                               data[evt].data[hitasicn,hitchn]-cmn[evt,hitasicn]+0.5)
                addadc=(((findgen(100)+0.5)/100.*(edepudn-edepldn)+edepldn)/binwidth)<(nbin-1)>0
                for l=0, 99 do begin
                    spec(addadc[l],hitchn,hitasicn,1)+=1/100./(edepudn-edepldn)
                    spec(addadc[l],64,hitasicn,1)+=1/100./(edepudn-edepldn)
                endfor

 
            endif
            
        endif
    endfor

    print, 'good events: ', ngood, '/', n_evts

  window, xsize = 800, ysize = 800
  ;x_axis = indgen(1124)-100
 !p.multi = [0, 2, 2]
  mm = max(spec[*,64,*,1])
  plot, spec[*,64,0,0],spec[*,64,0,1], xrange = [0, 100], yrange = [0, mm], $
    xtitle = 'ASIC 0',ytitle='counts/keV', psym = 10
  plot, spec[*,64,1,0],spec[*,64,1,1], xrange = [0, 100], yrange = [0, mm], $
    xtitle = 'ASIC 1',ytitle='counts/keV', psym = 10
  plot, spec[*,64,2,0],spec[*,64,2,1], xrange = [0, 100], yrange = [0, mm], $
    xtitle = 'ASIC 2',ytitle='counts/keV', psym = 10
  plot, spec[*,64,3,0],spec[*,64,3,1], xrange = [0, 100], yrange = [0, mm], $
    xtitle = 'ASIC 3',ytitle='counts/keV', psym = 10

;  if n_elements(file) eq 1 then save_name = file else save_name = file[0]
;  if keyword_set(subtract_common) then save_name = save_name + '_sub'
;  save_name = save_name + '.sav'
;  save, a0, a1, a2, a3, file = save_name
  
  return, spec
  
END
