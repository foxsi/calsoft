FUNCTION LIVETIME, TRIGGER, FRAME, DETECTOR, STOP=STOP, RATE=RATE, DEAD=DEAD, NHITS=NHITS, NTOT=NTOT

	hskp_time = 184  ; time for housekeeping words, in microsec

	; convert times to microseconds
	trg_time = trigger*0.1
	frm_time = frame*0.1

	trg_time1 = trg_time  ; for debugging
	frm_time1 = frm_time  ; for debugging

	i = where(trigger gt -1.0)
	trg_time = trg_time[i]
	frm_time = frm_time[i]

	setup = hskp_time + (detector+1)*264

	if n_elements(frm_time) ne n_elements(trg_time) then begin
		print, 'Number of elements in frame time not equal to n_elements in trigger time.'
		return, -1
	endif

	n = n_elements(frm_time)
	i = where(trg_time gt 0.0)
	nHits = n_elements(i)

	if nHits eq -1 then begin
		print, 'No triggers found.'
		return, -1
	endif

	livetime = dblarr(nHits+1)
	i = long(0)

	for j=long(1), n-1 do begin
	
		if trg_time[j] gt 0. then begin
;			if trg_time[j] lt (frm_time[j-1] + setup) then trg_time[j] = trg_time[j] + 2.^16*0.1
;			livetime[i] = livetime[i] + trg_time[j] - frm_time[j-1]
			livetime[i] = livetime[i] + trg_time[j] - frm_time[j-1] - setup
			i++;
		endif else livetime[i] = livetime[i] + 6./7.*2000.  ; if no trigger add 6/7 of a full frame time
;		if i eq 62 then stop

	endfor

	if keyword_set(stop) then stop

	n_tot = n_elements(frame)
	rate = float(nHits)/n_tot*500
	ntot = n_tot

	; try another way of doing it.  LT = total time live each frame.  DT=2ms - LT
	live2 = trg_time[1:n-1] - frm_time[0:n-2] - setup
	dead = 2000. - live2
	i=where(dead eq 2000.)
	if i[0] ne -1 then dead[i] = 0.

	return, livetime
;	return, live2

END