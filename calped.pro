FUNCTION CALPED, FILE, PEAKSFILE=PEAKSFILE, BADCH=BADCH, NBIN=NBIN, BINWIDTH=BINWIDTH, $
	CMN_MEDIAN = CMN_MEDIAN, SUBTRACT_COMMON = SUBTRACT_COMMON, GAUSS=GAUSS, $
	STOP = STOP

if not keyword_set(nbin) then nbin = 2000
if not keyword_set(peaksfile) then peaksfile = 'peaks.sav'
if not keyword_set(binwidth) then binwidth = 0.1

restore, file
restore, peaksfile

n_evts = n_elements(data)
print, n_evts, ' total events'

cmn = fltarr(n_evts, 4)
spec = fltarr(nbin, 65, 4, 2)
data_hist = fltarr(nbin, 65, 4, 2)
sub_hist = fltarr(nbin, 65, 4, 2)

 for as=0, 3 do begin
      if keyword_set(subtract_common) then cmn[*,as] = data[*].common_mode[as] + randomu(seed,n_evts*4+as) - 0.5
      if keyword_set(cmn_average) then cmn[*,as] = data[*].cmn_average[as]
      if keyword_set(cmn_median) then cmn[*,as] = data[*].cmn_median[as] + randomu(seed,n_evts*4+as) - 0.5
  endfor

   for as=0, 3 do begin
        for ch =0, 64 do begin
            spec[*, ch, as, 0] = (findgen(nbin)+0.5)*binwidth - 100.
	    data_hist[*, ch, as, 0] = findgen(nbin)+0.5 - 1000.
	    sub_hist[*, ch, as, 0] = findgen(nbin)+0.5 - 1000.
        endfor
    endfor

cal_data = fltarr(4, 64, n_evts)
sub_data = fltarr(4, 64, n_evts)
sigma_cal = fltarr(4, 65)
sigma_data = fltarr(4, 65)
sigma_sub = fltarr(4, 65)
mean_cal = fltarr(4, 65)
mean_data = fltarr(4, 65)
mean_sub = fltarr(4, 65)

for i=0, 3 do begin
	print, 'Calibrating ASIC ', i
	for j=0, 63 do begin
		sub_data[i,j,*] = float(data.data[i,j]-cmn[*,i])
		vector = reform(sub_data[i,j,*])
;		plot, findgen(1010)-10,histogram(vector,min=-10,max=1000)
		cal_data[i,j,*] = spline(peaks[*,j,i,0], peaks[*,j,i,1], vector[sort(vector)])
;		spec[*,j,i,1] = histogram(data.data[i,j]-cmn[*,i], min=-100, max=100, nbins=2000)
		spec[*,j,i,1] = histogram(cal_data[i,j,*], min=-100, max=100, nbins=2000)
		data_hist[*,j,i,1] = histogram(data.data[i,j,*], min=-1000, max=1000, nbins=2000)
		sub_hist[*,j,i,1] = histogram(vector, min=-1000, max=1000, nbins=2000)
	endfor
endfor

spec[*,64,*,1] = total(spec[*,*,*,1],2)
data_hist[*,64,*,1] = total(data_hist[*,*,*,1],2)
sub_hist[*,64,*,1] = total(sub_hist[*,*,*,1],2)

if keyword_set(gauss) then begin
	; compute Gaussian widths
	for i=0,3 do begin
		for j=0, 64 do begin
			a=gaussfit( spec[*,j,i,0], spec[*,j,i,1], params, nterms=3)
			sigma_cal[i,j] = params[2]
			mean_cal[i,j] = params[1]
			a=gaussfit( data_hist[*,j,i,0], data_hist[*,j,i,1], params, nterms=3)
			sigma_data[i,j] = params[2]
			mean_data[i,j] = params[1]
			a=gaussfit( sub_hist[*,j,i,0], sub_hist[*,j,i,1], params, nterms=3)
			sigma_sub[i,j] = params[2]
			mean_sub[i,j] = params[1]
		endfor
	endfor
	save, sigma_cal, sigma_data, sigma_sub, mean_cal, mean_data, mean_sub, file='gauss_sigma.sav'
endif

  window, xsize = 800, ysize = 800
  ;x_axis = indgen(1124)-100
 !p.multi = [0, 2, 2]
  mm = max(spec[1040:1999,64,*,1])
  plot, spec[*,64,0,0],spec[*,64,0,1], xrange = [0, 10], yrange = [0, mm], $
    xtitle = 'ASIC 0',ytitle='counts/keV', psym = 10
  plot, spec[*,64,1,0],spec[*,64,1,1], xrange = [0, 10], yrange = [0, mm], $
    xtitle = 'ASIC 1',ytitle='counts/keV', psym = 10
  plot, spec[*,64,2,0],spec[*,64,2,1], xrange = [0, 10], yrange = [0, mm], $
    xtitle = 'ASIC 2',ytitle='counts/keV', psym = 10
  plot, spec[*,64,3,0],spec[*,64,3,1], xrange = [0, 10], yrange = [0, mm], $
    xtitle = 'ASIC 3',ytitle='counts/keV', psym = 10

if keyword_set(stop) then stop

return, spec

END