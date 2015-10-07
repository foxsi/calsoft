;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION CALSPEC, FILE, PEAKSFILE = PEAKSFILE, THR = THR, BINWIDTH = BINWIDTH, $
              NBIN = NBIN, BADCH=BADCH, NMAX = NMAX, SUBTRACT_COMMON = SUBTRACT_COMMON, $
              CMN_AVERAGE = CMN_AVERAGE, CMN_MEDIAN = CMN_MEDIAN, STOP = STOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;if not keyword_set(savefile) then savefile = 'pedestal.sav'
  if not keyword_set(peaksfile) then peaksfile = 'peaks.sav'
  if not keyword_set(thr) then thr=5.0
  if not keyword_set(binwidth) then binwidth=0.1
  if not keyword_set(nbin) then nbin =1000
  if not keyword_set(badch) then badch=intarr(4,64)


  ; call preceding function to read in the data file(s).
  ;data = read_data_struct(file, subtract = subtract_common, stop = stop)

  restore,file
  restore,peaksfile

  n_evts = n_elements(data)
  print, n_evts, ' total events'

  cmn = fltarr(n_evts)
  spec = fltarr(nbin, 65, 4, 2)

  if keyword_set(subtract_common) then cmn = data.common_mode + randomu(seed,n_evts) - 0.5
  if keyword_set(cmn_average) then cmn = data.cmn_average 
  if keyword_set(cmn_median) then cmn = data.cmn_median + randomu(seed,n_evts) - 0.5

  ; debugging
  ;print, n_elements(i0), n_elements(i1), n_elements(i2), n_elements(i3)

  ; 

    for asic=0, 3 do begin
        for ch =0, 64 do begin
            spec[*, ch, asic, 0] = (findgen(nbin)+0.5)*binwidth   
        endfor
    endfor

;n_evts=100
    if keyword_set(nmax) then n_evts = nmax

    hitch=0
    for i = long(0), n_evts-1 do begin
        
        if (i mod 1000) eq 0 then print, 'Event  ', i, ' / ', n_evts
        hitchnum=0
        asic = data[i].asic
        
        if asic lt 4 and data[i].error_flag eq 0 then begin

            for ch = 0, 63 do begin

                edep = spline(peaks[*,ch,asic,0],peaks[*,ch,asic,1],data[i].data[ch]-cmn[i])

                if badch[asic,ch] eq 0 and edep gt thr then begin
                    hitchnum+=1
                    hitch=ch
                endif

            endfor

            if hitchnum eq 1 then begin
                edepld=spline(peaks[*,hitch,asic,0],peaks[*,hitch,asic,1],data[i].data[hitch]-cmn[i]-0.5)
                edepud=spline(peaks[*,hitch,asic,0],peaks[*,hitch,asic,1],data[i].data[hitch]-cmn[i]+0.5)

                addadc=(((findgen(100)+0.5)/100.*(edepud-edepld)+edepld)/binwidth)<(nbin-1)>0
                for l=0, 99 do begin
                    spec(addadc[l],hitch,asic,1)+=1/100./(edepud-edepld)
                    spec(addadc[l],64,asic,1)+=1/100./(edepud-edepld)
                endfor
            
            endif
            
        endif
    endfor

  ; save data in current directory with chosen name, for easy recall.
  ;save, a0, a1, a2, a3, file = savefile

  window, xsize = 800, ysize = 800
  ;x_axis = indgen(1124)-100
 !p.multi = [0, 2, 2]
  mm = max(spec[*,64,*,1])
  plot, spec[*,64,0,0],spec[*,64,0,1], xrange = [0, 100], yrange = [0, mm], $
    xtitle = 'ASIC 0',ytitle='counts/keV', psym = 10
  plot, spec[*,64,1,0],spec[*,64,1,1], xrange = [0, 100], yrange = [0, mm], $
    xtitle = 'ASIC 0',ytitle='counts/keV', psym = 10
  plot, spec[*,64,2,0],spec[*,64,2,1], xrange = [0, 100], yrange = [0, mm], $
    xtitle = 'ASIC 0',ytitle='counts/keV', psym = 10
  plot, spec[*,64,3,0],spec[*,64,3,1], xrange = [0, 100], yrange = [0, mm], $
    xtitle = 'ASIC 0',ytitle='counts/keV', psym = 10

;  if n_elements(file) eq 1 then save_name = file else save_name = file[0]
;  if keyword_set(subtract_common) then save_name = save_name + '_sub'
;  save_name = save_name + '.sav'
;  save, a0, a1, a2, a3, file = save_name
  
  return, spec
  
END
