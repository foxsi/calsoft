; IDL procedure by Athiray
; Copyright (c) 2017, FOXSI Mission University of Minnesota.  All rights reserved.
;       Unauthorized reproduction is allowed.


; Start		: 07 Jul 2017 15:09
; Last Mod 	: 31 Oct 2017 19:33

;-------------------  Details of the program --------------------------;
; IDL procedure by Athiray
; Copyright (c) 2017, FOXSI Mission University of Minnesota.  All rights reserved.
;       Unauthorized reproduction is allowed.

;copied from peaks_fe_ni_cu_am_gauss to include cr
; Start		: 18 Apr 2017 21:52
; Last Mod 	: 07 Jul 2017 14:55

;-------------------  Details of the program --------------------------;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO PEAKS_FE_NI_CU_AM_CR_gauss_detpos5, HISTFE=HISTFE, HISTAMNI=HISTAMNI,HISTAMCU=HISTAMCU, HISTAME=HISTAME, HISTCR=HISTCR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

npeak=9
peaks=fltarr(npeak+3, 64, 4, 2)
error=fltarr(npeak+3, 64, 4, 2)

; n-side
for asic=0, 1 do begin
    !p.multi=[0,3,2]
    set_plot,'ps'
    if asic eq 0 then fn='fitscr_asic0.eps' else fn= 'fitscr_asic1.eps'
    device,filename=fn;,/color,/encapsulated
    for ch=0, 63 do begin
        xxfe=histfe(*, ch, asic,0)
        yyfe=histfe(*, ch, asic,1)
        xxamni=histamni(*, ch, asic,0)
        yyamni=histamni(*, ch, asic,1)
        xxamcu=histamcu(*, ch, asic,0)
        yyamcu=histamcu(*, ch, asic,1)
	xxam=histame(*, ch, asic,0)
        yyam=histame(*, ch, asic,1)
	xxcr=histcr(*, ch, asic,0)
        yycr=histcr(*, ch, asic,1)

	peaks(*, ch, asic,1)=[0.0,0.0,5.895,7.47,8.04,13.93,17.611,59.54,4.99,0.0,0.0,0.0]
        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        ;peaks(npeak-2, ch, asic, 1)=peaks(npeak-3, ch, asic, 1)*2-peaks(npeak-4, ch, asic, 1)
        ;peaks(npeak-1, ch, asic, 1)=peaks(npeak-2, ch, asic, 1)*2-peaks(npeak-3, ch, asic, 1)
        peaks(npeak  , ch, asic, 1)=peaks(npeak-1, ch, asic, 1)*2-peaks(npeak-2, ch, asic, 1)
        peaks(npeak+1, ch, asic, 1)=peaks(npeak  , ch, asic, 1)*2-peaks(npeak-1, ch, asic, 1)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*2-peaks(npeak  , ch, asic, 1)

        peaks(1, ch, asic, 0)=find_peak(xxamni,yyamni,-20, 20,4, 1)
        ;peaks(2, ch, asic, 0)=find_peak(xxfe,yyfe, 40, 80,1, 8)
        gauss_peak=find_gauss(xxfe,yyfe, 35,80,1, 2)
	peaks(2, ch, asic, 0)=gauss_peak[0]
	error(2, ch, asic, 0)= gauss_peak[1]

	;peaks(3, ch, asic, 0)=find_peak(xxamni,yyamni,50,75,2, 8)
	peaks(4, ch, asic, 0)=find_peak(xxamcu,yyamcu,60,80,2, 8)
        peaks(3, ch, asic, 0)=find_peak(xxamni,yyamni, 50,peaks(4,ch,asic,0)-5,2,8)
	print,peaks(3,ch,asic,0),peaks(4,ch,asic,0)
	;peaks(5, ch, asic, 0)=find_peak(xxam,yyam,100,130,2, 8)
        gauss_peak=find_gauss(xxam,yyam, 95,130,1,2)
	peaks(5, ch, asic, 0)=gauss_peak[0]
	error(5, ch, asic, 0)= gauss_peak[1]


	;peaks(6, ch, asic, 0)=find_peak(xxam,yyam,130,155,2,16)
        gauss_peak=find_gauss(xxam,yyam, 125,165,1,2)
	peaks(6, ch, asic, 0)=gauss_peak[0]
	error(6, ch, asic, 0)= gauss_peak[1]



	;peaks(7, ch, asic, 0)=find_peak(xxam,yyam,350,400,2,16)
	gauss_peak=find_gauss(xxam,yyam, 350,410,1,2)
	peaks(7, ch, asic, 0)=gauss_peak[0]
	error(7, ch, asic, 0)= gauss_peak[1]

	gauss_peak=find_gauss(xxcr,yycr, 28,50,1,2)
	peaks(8, ch, asic, 0)=gauss_peak[0]
	error(8, ch, asic, 0)= gauss_peak[1]

	;gauss_peak=find_gauss(xxcr,yycr, 28,50,1,2)
        gauss_peak=find_gauss(xxcr,yycr, 32,peaks(2,ch,asic,0)-5,1,2)
	if gauss_peak[0] lt 30 then peaks(8, ch, asic,0) = peaks(2,ch,asic,0)-5 else peaks(8, ch, asic, 0)=gauss_peak[0]
	error(8, ch, asic, 0)= gauss_peak[1]

        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        ;peaks(npeak-2, ch, asic, 0)=peaks(npeak-3, ch, asic, 0)*2-peaks(npeak-4, ch, asic, 0)
        ;peaks(npeak-1, ch, asic, 0)=peaks(npeak-2, ch, asic, 0)*2-peaks(npeak-3, ch, asic, 0)
        peaks(npeak  , ch, asic, 0)=peaks(npeak-1, ch, asic, 0)*2-peaks(npeak-2, ch, asic, 0)
        peaks(npeak+1, ch, asic, 0)=peaks(npeak  , ch, asic, 0)*2-peaks(npeak-1, ch, asic, 0)
        peaks(npeak+2, ch, asic, 0)=peaks(npeak+1, ch, asic, 0)*2-peaks(npeak  , ch, asic, 0)

    endfor
endfor
device,/close
set_plot,'x'

; p-side
for asic=2, 3 do begin
    !p.multi=[0,3,3]
    set_plot,'ps'
    if asic eq 2 then fn='fitscr_asic2.eps' else fn= 'fitscr_asic3.eps'
    device,filename=fn;,/color,/encapsulated
    for ch=0, 63 do begin
        xxfe=histfe(*, ch, asic,0)
        yyfe=histfe(*, ch, asic,1)
        xxamni=histamni(*, ch, asic,0)
        yyamni=histamni(*, ch, asic,1)
        xxamcu=histamcu(*, ch, asic,0)
        yyamcu=histamcu(*, ch, asic,1)
        xxam=histame(*, ch, asic,0)
        yyam=histame(*, ch, asic,1)
	xxcr=histcr(*, ch, asic,0)
        yycr=histcr(*, ch, asic,1)


        ;peaks(*, ch, asic, 1)=[0.0,0.0,5.895,13.93,17.611,20.9,30.85,34.96,59.54,0.0]
        ;peaks(*, ch, asic, 1)=[0.0,0.0,5.895,7.48,8.26,8.04,8.91,13.93,17.611,20.9,59.54,0.0]
        ;peaks(*, ch, asic,1)=[0.0,0.0,5.895,7.48,8.04,13.93,17.611,20.9,26.34,59.54,0.0]
        peaks(*,ch,asic,1)=[0.0,0.0,5.895,7.47,8.04,13.93,17.611,20.9,26.3,59.54,4.99,0.0]

        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*2-peaks(npeak, ch, asic, 1)

        peaks(1, ch, asic, 0)=find_peak(xxam,yyam,-20, 20,4, 1)
        ;peaks(2, ch, asic, 0)=find_peak(xxfe,yyfe, 40,80,3, 2)
	gauss_peak=find_gauss(xxfe,yyfe, 30,80,1, 1)
	peaks(2, ch, asic, 0)=gauss_peak[0]
	error(2, ch, asic, 0)= gauss_peak[1]

	;peaks(3, ch, asic, 0)=find_peak(xxamni,yyamni, 50,85,3, 6)
        gauss_peak=find_gauss(xxamni,yyamni, 50,80,2,2)
	peaks(3, ch, asic, 0)=gauss_peak[0]
	error(3, ch, asic, 0)= gauss_peak[1]




	;peaks(4, ch, asic, 0)=find_peak(xxamcu,yyamcu, 60,100,3, 5)
	gauss_peak=find_gauss(xxamcu,yyamcu, 60,100,1,1)
	peaks(4, ch, asic, 0)=gauss_peak[0]
	error(4, ch, asic, 0)= gauss_peak[1]
	;peaks(6, ch, asic, 0)=find_peak(xxam,yyam,170,200,3, 4)
        ;peaks(6, ch, asic, 0)=find_peak(xxam,yyam,165,190,3, 2)

	;commented to change range of peak selection for det. pos.6
	;gauss_peak=find_gauss(xxam,yyam, 165,190,1,1)
	gauss_peak=find_gauss(xxam,yyam, 165,205,1,1)
	peaks(6, ch, asic, 0)=gauss_peak[0]
	error(6, ch, asic, 0)= gauss_peak[1]


        ;peaks(5, ch, asic, 0)=find_peak(xxam,yyam,120,peaks(6,ch,asic,0)-35,3, 4)
        gauss_peak=find_gauss(xxam,yyam, 120,peaks(6,ch,asic,0)-35,1,1)
	peaks(5, ch, asic, 0)=gauss_peak[0]
	error(5, ch, asic, 0)= gauss_peak[1]


	;peaks(5, ch, asic, 0)=find_peak(xxamcu,yyamcu,100,peaks(6, ch, asic, 0)-30,3, 2)
        ;peaks(7, ch, asic, 0)=find_peak(xxamcu,yyamcu,peaks(6, ch, asic, 0)+30,300,3, 4)
        ;peaks(7, ch, asic, 0)=find_peak(xxam,yyam,200,245,3,5)

	;commented to change range of peak selection for det. pos.6
	;gauss_peak=find_gauss(xxam,yyam, 200,245,1,1)
	gauss_peak=find_gauss(xxam,yyam, 200,255,1,1)
	peaks(7, ch, asic, 0)=gauss_peak[0]
	error(7, ch, asic, 0)= gauss_peak[1]

	;peaks(8, ch, asic, 0)=find_peak(xxam,yyam,260,290,3,2)

	gauss_peak=find_gauss(xxam,yyam, 260,300,2,2)
	peaks(8, ch, asic, 0)=gauss_peak[0]
	error(8, ch, asic, 0)= gauss_peak[1]


	;peaks(9, ch, asic, 0)=find_peak(xxam,yyam,680,750,2,8)
	gauss_peak=find_gauss(xxam,yyam, 680,750,2,4)
	peaks(9, ch, asic, 0)=gauss_peak[0]
	error(9, ch, asic, 0)= gauss_peak[1]



	gauss_peak=find_gauss(xxcr,yycr, 30,70,1,1)
	peaks(10, ch, asic, 0)=gauss_peak[0]
	error(10, ch, asic, 0)= gauss_peak[1]


        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        peaks(npeak+2, ch, asic, 0)=peaks(npeak+1, ch, asic, 0)*2-peaks(npeak, ch, asic, 0)
	print,asic,ch
    endfor
endfor
device,/close
set_plot,'x'
;stop
;stop

;save,peaks,file='peaks_fe_ni_cu_am.sav'
save,peaks,file='peaks_fe_ni_cu_upsideam_cr_gauss.sav'

stop
END


