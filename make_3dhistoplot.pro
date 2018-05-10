FUNCTION CUSTOM_CTABLE


  steps=85
  scaleFactor = FINDGEN(STEPS) / (steps-1)

  redvector = [255, replicate(0, steps) ]   ; red vector 0 to 0
  bluevector = [255, replicate(255, steps)] ; blue vector 255 to 255

  redvector = [redvector, 0 + (200-0)*scalefactor]     ; red vector 0 to 150
  bluevector = [bluevector, 255 + (0-255)*scalefactor] ; blue vector 255 to 0

  redvector =  [redvector, 200+ (255-200)*scalefactor]    ; red vector 150 to 255
  bluevector = [bluevector, replicate(0, steps)]     ; blue vector 0 to 0

  steps=127
  scaleFactor = FINDGEN(STEPS) / (steps-1)

  greenvector = [255, 0 + (255 - 0) * scaleFactor ]                 ; green vector 0 to 255
  greenvector = [GREENVECTOR, 255 + (150 - 255) * scaleFactor, 150 ]                 ; green vector 255 to 150
 ; greenvector = [greenvector, replicate(255,steps), 255] ;  green vector 255 to 255

  TVLCT, redVector, greenVector, blueVector
 ; TVSCL, DIST(400)

  ctable = [[byte(redvector)], [byte(greenvector)], [byte(bluevector)]]
  return, CTABLE
  
end


FUNCTION read_histo_in_array, h

  ;+
  ; description
  ;   this function takes a foxsi histogram object and return a 2d array where the xaxis are the strips for the 4 asics
  ;   and the y axis are the adu channels
  ;
  ; input
  ;   h: histogram (array of size 1124,64,42 )
  ;-
  
  array = fltarr(64*4,1124)
  FOR ASIC=0, 3 DO BEGIN
    FOR ch=0, 63 DO  array[asic*64+ch,*]=h[*,ch,asic,1]
  ENDFOR
  RETURN, array
  
END


PRO make_3dhistoplot, h, SAVEPLOT=SAVEPLOT, plotname=plotname, max_data=max_data, plotlog=plotlog, _extra=extra

;+ 
; description
;   this procedure takes a foxsi histogram or an array of histograms and produce a plot with all strips and asic histrograms ......
;
; input
;   h: histogram or A LIST of histograms
;
; keywords
;   saveplot
;   plotname
;   max_data: if set, all values above this value will be set to this value. useful for color scaling
;
; example
;   f = 'data_180327_181355.dat'
;   str = 'struct_D'+strtrim(detnum,2)+'_'+f
;   h3=makehist(str,/sub) ; assuming the structure has already been saved
;   make_3dhistoplot, h3, title='FEC09 Am sub', yr=[-10,500]
;   
; calls
;   read_histo_in_array
;   
; warning
;   This procedure calls the function image of IDL, if you have an old version of 
;   calsoft there will be a conflict with the image.pro there
;   
; history
;   Sophie M, UMN, 2018/03/27: release
;   Sophie M, UMN, 2018/05/10: added new color table and data_max keyword, and plotlog keyword
;-

DEFAULT, aspect_ratio, 0.2
default, SAVEPLOT, 0
DEFAULT, plotname, "plot.eps"
DEFAULT, plotlog, 1

; ckeck type of input and proceed only if recognized
type=typename(h)
IF type NE 'LIST' AND type NE 'FLOAT' THEN BEGIN
  print, 'input must be a FOXSI histogram or a LIST of FOXSI histograms'
ENDIF ELSE BEGIN

; if we have a list of histograms then we will add all the histograms together
  IF type EQ 'LIST' THEN BEGIN
    nlist = n_elements(h)
    array = read_histo_in_array(h[0])
    FOR k=0, nlist-1 DO array = array+read_histo_in_array(h[k])
    ; define yaxis of the plot with the first histogram of the list
    his = h[0]
    yaxis = his[*,0,0,0]

; if we have only one histogram nothing more to do
  ENDIF ELSE BEGIN
    array = read_histo_in_array(h)
    ; define yaxis of the plot
    yaxis = h[*,0,0,0]
  ENDELSE
  
  ; define colortable to be use
  ct = colortable(27)
  CT = CUSTOM_CTABLE()
  
  ; define xaxis of the plot
  xaxis = indgen(64*4)
  
  IF keyword_set(max_data) theN begin
    ABOVE = where(array GT max_data)
    array(above) = max_data
  ENDIF
  IF plotlog EQ 1 THEN array=alog10(array)
  ; plot
  i = image(array, xaxis, yaxis, rgb_table=ct, AXIS_STYLE=2, aspect_ratio=aspect_ratio, dimensions=[1400,1200], position=[0.1,0.1,0.88,0.9], $
    xmajor=5, xminor=8, _extra=extra)
  tval = indgen(round(max(array))-1)+1
  c = colorbar(target=i, orientation=1, tickvalues=tval, tickname= string(10^tval), position=[0.96,0.2,0.99,0.8], font_size=i.font_size )
  IF SAVEPLOT EQ 1 THEN i.Save, plotname, BORDER=10, RESOLUTION=600, BIT_DEPTH=2
ENDELSE

END