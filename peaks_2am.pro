;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO PEAKS_2AM, HIST
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

npeak=2
peaks=fltarr(npeak+3, 64, 4, 2)

; n-side
for asic=0, 1 do begin
    for ch=0, 63 do begin

        xx=hist(*, ch, asic,0)
        yy=hist(*, ch, asic,1)

        peaks(*, ch, asic, 1)=[0.0,0.0,17.611,59.54,0.0]
        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*20-peaks(npeak, ch, asic, 1)*19

        peaks(1, ch, asic, 0)=0.0
        peaks(2, ch, asic, 0)=find_peak(xx,yy,100,220,2,8)
        peaks(3, ch, asic, 0)=find_peak(xx,yy,500,600,2,8)

        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        peaks(npeak+2, ch, asic, 0)=peaks(npeak+1, ch, asic, 0)*20-peaks(npeak, ch, asic, 0)*19
    endfor
endfor

; p-side
for asic=2, 3 do begin
    for ch=0, 63 do begin

        xx=hist(*, ch, asic,0)
        yy=hist(*, ch, asic,1)

        peaks(*, ch, asic, 1)=[0.0,0.0,17.611,59.54,0.0]
        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*2-peaks(npeak, ch, asic, 1)

        peaks(1, ch, asic, 0)=0.0
        peaks(2, ch, asic, 0)=find_peak(xx,yy,100,230,3,2)
        peaks(3, ch, asic, 0)=find_peak(xx,yy,500,900,3,4)

        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        peaks(npeak+2, ch, asic, 0)=peaks(npeak+1, ch, asic, 0)*2-peaks(npeak, ch, asic, 0)
    endfor
endfor

save,peaks,file='peaks.sav'

END


