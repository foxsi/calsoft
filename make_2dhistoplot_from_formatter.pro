PRO make_2dhistoplot_from_formatter, list, detnum, dir=dir, title=title, nosave=nosave, plotname=plotname, _extra=extra

;+
; :description:
;   This procedure takes a list of formatter files and produce an histoplot that will be saved with a name including the date and time of the first file
;   
; :input:
;   list: list of string containing the names of the formatter files
;   detnum: list of detector number
;  
; :keywords:
;   dir: directory for the files. If not set, default is current directory
;   title: title of the plot. default is 'Formatter'
;   nosave: set to 1 to not save the plot
;   plotname: string containing the name of the plot
;   
; :calls:
;   formatter_packet
;   makehist
;   make_3dhistoplot
;   
; :example:
; 
; :history:
;   2018/05/14 - Sophie M, UMN, initial release
;-
  nfiles = n_elements(list)
  name = strsplit(list[0],'.',/extract)
  cd, current=currentdir
  DEFAULT, dir, currentdir+'\'
  DEFAULT, plotname, '2dhisto_formatter_'+name[0]+'.eps'
  DEFAULT, noplot, 0
  DEFAULT, title, 'Formatter '+name[0]+' with '+strsplit(string(nfiles),/extract)+' files'
  
  ndetnum = n_elements(detnum)
  
  ; If we have a list of files but only one detnum specified, replicate that number
  IF nfiles GT 1 AND ndetnum EQ 1 THEN detnum = replicate(detnum, nfiles)

  hist = list()
  ; read all files and create a list of histogram data
  FOR k=0, nfiles-1 DO BEGIN
    f=list[k]
    det=detnum[k]
    data=formatter_packet(dir+f,det)
    str = 'struct_D'+strtrim(det,2)+'_'+f
    save,data,file=str
    h=makehist(str,/sub)
    hist.add, h
  ENDFOR
  
   IF noplot EQ 1 THEN saveplot=0 ELSE BEGIN 
    saveplot=1
    print, 'Will save file ', plotname
  ENDELSE
  make_3dhistoplot, h, saveplot=saveplot, plotname=plotname, title=title, _extra=extra
END