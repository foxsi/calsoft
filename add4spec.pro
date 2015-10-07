;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION ADD4SPEC, HIST1, HIST2, HIST3, HIST4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  if not keyword_set(rebin) then rebin=1

nbin=(size(hist1(*,0,0,0)))(1)
hh=fltarr(nbin, 65,  4, 2)
  for ch = 0, 64 do begin
      for adcch =0, nbin-1 do begin
          for asic = 0, 3 do begin
              hh(adcch, ch, asic, 0) = hist1(adcch, ch, asic, 0)
              hh(adcch, ch, asic, 1) = hist1(adcch, ch, asic, 1)+hist2(adcch, ch, asic, 1)+hist3(adcch, ch, asic, 1)+hist4(adcch, ch, asic, 1)
          endfor
      endfor
  endfor

return, hh

END


