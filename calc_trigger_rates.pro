; IDL procedure by Athiray
; Copyright (c) 2017, FOXSI Mission University of Minnesota.  All rights reserved.
;       Unauthorized reproduction is allowed.

;+ 
; PROJECT
;   FOXSI CALSOFT
;   
; DESCRIPTION
;   This function calculates and returns the trigger rates for each detector for one formatter file
;   
; INPUT
;   file: string with the name of the formatter file
;
; OUTPUT
;   An array of 7 double numbers, containing the trigger rate in cts/sec for each detector.
;   
; KEYWORD
;   loud, set to 1 for the trigger rates to be printed, default is 1
;   quiet, set to disable result printing. When set, loud is ignored.
; 
; CALLS
;   formatter_packet
;   
; EXAMPLE
;   rate = calc_trigger_rates('.dat')
;   
; HISTORY  
;   Start		  : 19 Jul 2018 01:02 - Athiray
;   Last Mod 	: 20 Jul 2018 20:19 - Athiray
;   2018/10/12 - SMusset (UMN) - added keyword loud, completed header and added to calsoft
;-

function calc_trigger_rates, file, loud=loud, quiet=quiet

  ; initialization
  DEFAULT, loud, 1
  IF keyword_set(quiet) THEN loud=0
  trigger_rate=dblarr(7)

  ; loop over detectors
  for detnum=0,6 do begin
    detector=detnum
    data=formatter_packet(file,detector,trig_time=trig_time);,/stop)
    nonzero = where(trig_time ne 0)
    rate = n_elements(nonzero)
    nframes = n_elements(data)
    rate = 500.*rate / nFrames
    trigger_rate[detnum]=rate
    ;print,'Trigger rate is (cts/s):',rate
  endfor
  IF loud EQ 1 THEN print,'Trigger rate (cts/s) ', trigger_rate    

  return, trigger_rate

END

