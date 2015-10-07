;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO PEAKS_FE_4AM, HISTFE=HISTFE, HISTAM=HISTAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

npeak=5
peaks=fltarr(npeak+3, 64, 4, 2)

; n-side
for asic=0, 1 do begin
    for ch=0, 63 do begin

        xxfe=histfe(*, ch, asic,0)
        yyfe=histfe(*, ch, asic,1)
        xxam=histam(*, ch, asic,0)
        yyam=histam(*, ch, asic,1)

        peaks(*, ch, asic, 1)=[0.0,0.0,5.895,17.611,59.54,0.0,0.0,0.0]
        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        peaks(npeak  , ch, asic, 1)=peaks(npeak-1, ch, asic, 1)*2-peaks(npeak-2, ch, asic, 1)
        peaks(npeak+1, ch, asic, 1)=peaks(npeak  , ch, asic, 1)*2-peaks(npeak-1, ch, asic, 1)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*2-peaks(npeak  , ch, asic, 1)

        peaks(1, ch, asic, 0)=0.0
        peaks(2, ch, asic, 0)=find_peak(xxfe,yyfe, 80,150,3, 8)
        peaks(3, ch, asic, 0)=find_peak(xxam,yyam,150,400,4,16)
        peaks(4, ch, asic, 0)=find_peak(xxam,yyam,700,900,2,32)

        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        peaks(npeak  , ch, asic, 0)=peaks(npeak-1, ch, asic, 0)*2-peaks(npeak-2, ch, asic, 0)
        peaks(npeak+1, ch, asic, 0)=peaks(npeak  , ch, asic, 0)*2-peaks(npeak-1, ch, asic, 0)
        peaks(npeak+2, ch, asic, 0)=peaks(npeak+1, ch, asic, 0)*2-peaks(npeak  , ch, asic, 0)

    endfor
endfor

; p-side
for asic=2, 3 do begin
    for ch=0, 63 do begin

        xxfe=histfe(*, ch, asic,0)
        yyfe=histfe(*, ch, asic,1)
        xxam=histam(*, ch, asic,0)
        yyam=histam(*, ch, asic,1)

        peaks(*, ch, asic, 1)=[0.0,0.0,5.895,13.93,17.611,20.9,59.54,0.0]
        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*2-peaks(npeak, ch, asic, 1)

        peaks(1, ch, asic, 0)=0.0
        peaks(2, ch, asic, 0)=find_peak(xxfe,yyfe, 40,100,3, 4)
        peaks(4, ch, asic, 0)=find_peak(xxam,yyam,170,230,3, 4)
        peaks(3, ch, asic, 0)=find_peak(xxam,yyam,100,peaks(4, ch, asic, 0)-30,3, 4)
        peaks(5, ch, asic, 0)=find_peak(xxam,yyam,peaks(4, ch, asic, 0)+30,280,2, 8)
        peaks(6, ch, asic, 0)=find_peak(xxam,yyam,650,900,2,16)

        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        peaks(npeak+2, ch, asic, 0)=peaks(npeak+1, ch, asic, 0)*2-peaks(npeak, ch, asic, 0)
    endfor
endfor

save,peaks,file='peaks.sav'

END


