FUNCTION CAL_ORIENTED_QUICK_IMAGE, input, detnum, str=str, gse=gse, laser=laser, cdte=cdte, $
               plot_image=plot_image, saveplot=saveplot, plotname=plotname, loud=loud, _extra=extra

  ;+
  ;   :description:
  ; This function takes or produce a quick image, and rotate and mirror it to have it oriented as the user wants:
  ; - case 1: detector coordinates: in that case, no rotation and no mirror is done, this is just the product of the image_quick function
  ;           Note that in detector coordinates, we already have an image of the source, the only thing missing is the rotation
  ; - case 2: oriented as in the GSE software: this is useful to see the image of the source moving in the same direction of the physical source motion
  ;           In that case, only a rotation is applied to the image in detector coordinates
  ; - case 3: oriented as for comparison with the LASER images: this is the image as produced on the detector
  ;           In that case, on top of the rotation, we flip the image in both X and Y direction to imitate the image production of the detector by our telescope
  ; Note that this procedure is valid for FOXSI3 Si and CdTe detectors (FOXSI2 CdTe detectors probably have a different geometry)
  ; Note that the default configuration in this procedure is the FOXSI3 flight configuration, meaning that position 3 and 5 are CdTe detectors
  ;
  ;   :input:
  ; input: can be 1. an 128x128 image array (usually produced by the image_quick function)
  ;               2. a string, giving the name of a structure file (input to image_quick), if the keyword /str is set
  ;                  In that case the function will call quick_image with common mode substraction, no bad channel and no energy range specified
  ; detnum: detector number
  ;
  ;   :keywords:
  ; str:        set to 1 to read a structure file and create the image (common mode subtracted)
  ; gse:        set to 1 to produce a source image in the right orientation (source orientation)
  ; laser:      set to 1 to produce a source image as produced on the detector (inverted), which can be compared to the LASER images
  ; cdte:       set to 1 if the detector is one of the FOXSI3 CdTe (geometry is different) - FOR detnum 3 and 5 THIS IS ALREADY IMPLEMENTED IN THE CODE
  ; plot_image: set to 1 to plot the resulting image
  ; saveplot:   set to 1 to save the plot (if saveplot is 1 then plot_image is set to 1)
  ; plotname:   string, name of the png file to be created
  ; loud        set to 1 to print messages
  ; 
  ;   :call:
  ; image_quick.pro
  ; 
  ;   :example 1:
  ; f='data_180717_185517.dat'
  ; detnum=0
  ; str = 'struct_D'+strtrim(detnum,2)+'_'+f
  ; img = CAL_ORIENTED_QUICK_IMAGE(str, detnum, /str, /gse, /plot_image, /loud)
  ;   
  ;   :example 2:
  ; f='data_180717_185517'
  ; detnum=0
  ; str = 'struct_D'+strtrim(detnum,2)+'_'+f+'.dat' 
  ; img0 = image_quick(str, /subtract, badch=badch, CHRANGE=[50,600])
  ; img = CAL_ORIENTED_QUICK_IMAGE(img0, detnum, /laser, /saveplot, plotname=f+'_aligned.png')
  ;
  ;   :example 3:
  ; f='data_180717_185517.dat'
  ; detnum=5
  ; str = 'struct_D'+strtrim(detnum,2)+'_'+f
  ; img = CAL_ORIENTED_QUICK_IMAGE(str, detnum, /str, /gse, /plot_image, /loud, max=5)
  ;
  ;  :history:
  ; 2018-07-18 SM, UMN, creation
  ; 2018-07-26 SM, UMN, add keywords gse, laser, loud
  ; 2018-08-02 SM, UMN, add keyword cdte + foxsi3 config (position 3 and 5 are automatically considered as cdte unless specified otherwise)
  ;-

  ;---------------------------------------------------------
  ; DEFAULT VALUES AND INITIALISATION
  ;---------------------------------------------------------

  DEFAULT, str, 0
  DEFAULT, gse, 0
  DEFAULT, laser, 0
  DEFAULT, cdte, 0
  DEFAULT, plot_image, 0
  DEFAULT, saveplot, 0
  DEFAULT, plotname, 'oriented_image.png'
  DEFAULT, loud, 0
  DEFAULT, CdTe, 0
  
  IF laser EQ 1 AND gse EQ 1 THEN BEGIN
    print,'keywords GSE and LASER are both set to 1: choose to keep LASER'
    gse = 0
  ENDIF
  IF saveplot EQ 1 then plot_image=1

  CD, current=current_dir

  ;---------------------------------------------------------
  ; Default setup is FOXSI-3 flight
  ;---------------------------------------------------------

  ; If the cdte keyword is not mentionned, then assume that we have CdTe detectors in position 3 and 5
  IF keyword_set(cdte) EQ 0 AND (detnum EQ 3 or detnum EQ 5) THEN CdTe = 1
  ; If the keyword is already set to 1, this will not change
  ; If we want to use position 3 and 5 as Si detectors then one need to specify cdte=0

  ;---------------------------------------------------------
  ; define rotation angles for each detector
  ;---------------------------------------------------------

  angle = [82.5000, 75.0000, -67.5000, -75.0000, 97.5000, 90.0000, -60.0000]

  ;---------------------------------------------------------
  ; read or create the image file
  ;---------------------------------------------------------

  IF str EQ 1 THEN BEGIN
    IMG = IMAGE_QUICK(INPUT,/subtract)   ; IF str keyword is set, then the input is a structure file and we call image_quick
  ENDIF ELSE BEGIN 
    IMG = INPUT                          ; ELSE, then the input is already an image array
  ENDELSE

  ;---------------------------------------------------------
  ; if cdte, apply reflexion
  ;---------------------------------------------------------

  IF cdte EQ 1 THEN img = reverse(img,2)

  ;---------------------------------------------------------
  ; If specified, rotate the image
  ;---------------------------------------------------------

  IF gse EQ 1 OR laser EQ 1 THEN BEGIN
    img = rot(img, angle[detnum], /interp) 
    IF loud EQ 1 THEN print, ' image has been rotated'
  ENDIF

  ;---------------------------------------------------------
  ; If specified, reverse the image
  ;---------------------------------------------------------

  IF laser EQ 1 THEN BEGIN
    img = reverse(img,1)
    img = reverse(img,2)
    IF loud EQ 1 THEN print, ' image has been reversed'
  ENDIF

  ;---------------------------------------------------------
  ; If specified, plot and save the image
  ;---------------------------------------------------------

  IF plot_image EQ 1 THEN BEGIN
    im = image(img, dimensions=[900,900], margin=0.01, _extra=extra)
    IF saveplot EQ 1 THEN BEGIN 
      im.Save, plotname, BORDER=10, RESOLUTION=300 ; save the plotted image in png
      IF loud EQ 1 THEN print, plotname, ' has been saved in ', current_dir
    ENDIF
  ENDIF
  
  ;---------------------------------------------------------
  ; Return the resulting image
  ;---------------------------------------------------------  
  RETURN, img

END