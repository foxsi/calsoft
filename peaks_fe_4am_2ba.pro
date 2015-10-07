;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO PEAKS_FE_4AM_2BA, HISTFE=HISTFE, HISTAM=HISTAM, HISTBA=HISTBA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

npeak=7
peaks=fltarr(npeak+3, 64, 4, 2)

; n-side
for asic=0, 1 do begin
    for ch=0, 63 do begin

        xxfe=histfe(*, ch, asic,0)
        yyfe=histfe(*, ch, asic,1)
        xxam=histam(*, ch, asic,0)
        yyam=histam(*, ch, asic,1)

        peaks(*, ch, asic, 1)=[0.0,0.0,5.895,17.611,59.54,0.0,0.0,0.0,0.0,0.0]
        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        peaks(npeak-2, ch, asic, 1)=peaks(npeak-3, ch, asic, 1)*2-peaks(npeak-4, ch, asic, 1)
        peaks(npeak-1, ch, asic, 1)=peaks(npeak-2, ch, asic, 1)*2-peaks(npeak-3, ch, asic, 1)
        peaks(npeak  , ch, asic, 1)=peaks(npeak-1, ch, asic, 1)*2-peaks(npeak-2, ch, asic, 1)
        peaks(npeak+1, ch, asic, 1)=peaks(npeak  , ch, asic, 1)*2-peaks(npeak-1, ch, asic, 1)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*2-peaks(npeak  , ch, asic, 1)

        peaks(1, ch, asic, 0)=find_peak(xxam,yyam,-20, 20,4, 1)
        peaks(2, ch, asic, 0)=find_peak(xxfe,yyfe, 40, 80,1, 8)
        peaks(3, ch, asic, 0)=find_peak(xxam,yyam,140,200,2, 8)
        peaks(4, ch, asic, 0)=find_peak(xxam,yyam,350,500,2,16)

        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        peaks(npeak-2, ch, asic, 0)=peaks(npeak-3, ch, asic, 0)*2-peaks(npeak-4, ch, asic, 0)
        peaks(npeak-1, ch, asic, 0)=peaks(npeak-2, ch, asic, 0)*2-peaks(npeak-3, ch, asic, 0)
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
        xxba=histba(*, ch, asic,0)
        yyba=histba(*, ch, asic,1)

        peaks(*, ch, asic, 1)=[0.0,0.0,5.895,13.93,17.611,20.9,30.85,34.96,59.54,0.0]
        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*2-peaks(npeak, ch, asic, 1)

        peaks(1, ch, asic, 0)=find_peak(xxam,yyam,-20, 20,4, 1)
        peaks(2, ch, asic, 0)=find_peak(xxfe,yyfe, 50,100,3, 4)
;        peaks(2, ch, asic, 0)=find_peak(xxfe,yyfe, 20,100,3, 4)  ; d110
        peaks(4, ch, asic, 0)=find_peak(xxam,yyam,180,230,2, 2)
;        peaks(4, ch, asic, 0)=find_peak(xxam,yyam,120,150,2, 2)  ; asic 2 d110
;        peaks(4, ch, asic, 0)=find_peak(xxam,yyam,70,100,2, 2)  ; asic 3 d110
        peaks(3, ch, asic, 0)=find_peak(xxam,yyam,100,peaks(4, ch, asic, 0)-30,3, 2)
        peaks(5, ch, asic, 0)=find_peak(xxam,yyam,peaks(4, ch, asic, 0)+30,300,3, 4)
        peaks(6, ch, asic, 0)=find_peak(xxba,yyba,300,400,3,3)
;        peaks(6, ch, asic, 0)=find_peak(xxba,yyba,200,270,3,3)  ; asic 2 d110
;        peaks(6, ch, asic, 0)=find_peak(xxba,yyba,200,230,3,3)  ; asic 3 d110
        peaks(7, ch, asic, 0)=find_peak(xxba,yyba,peaks(6, ch, asic, 0)+30,500,3,6)
;        peaks(7, ch, asic, 0)=find_peak(xxba,yyba,peaks(6, ch, asic, 0)+20,500,3,6) ; asic3 d110
        peaks(8, ch, asic, 0)=find_peak(xxam,yyam,650,900,2,8)
;        peaks(8, ch, asic, 0)=find_peak(xxam,yyam,400,600,2,8)  ; asic 2 d110


        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        peaks(npeak+2, ch, asic, 0)=peaks(npeak+1, ch, asic, 0)*2-peaks(npeak, ch, asic, 0)
    endfor
endfor

save,peaks,file='peaks.sav'

END

