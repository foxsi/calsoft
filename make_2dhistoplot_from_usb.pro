PRO make_2dhistoplot_from_usb, list, title=title, dir=dir, nosave=nosave, plotname=plotname, _extra=extra

  ;+
  ; :description:
  ;   This procedure takes a list of usb files and produce an histoplot that will be saved with a name including the date and time of the first file
  ;
  ; :input:
  ;   list: list of string containing the names of the formatter files
  ;
  ; :keywords:
  ;   dir: directory for the files. If not set, default is current directory
  ;   title: title of the plot. default is 'Formatter'
  ;   nosave: set to 1 to not save the plot
  ;   plotname: string containing the name of the plot
  ;
  ; :calls:
  ;   read_data_struct_cal
  ;   makehist
  ;   make_3dhistoplot
  ;
  ; :example:
  ;   listfiles = list('data_180315_141725.dat', 'data_180315_142734.dat', 'data_180315_143355.dat')
  ;   make_2dhistoplot_from_formatter, listfiles, 6
  ;
  ; :history:
  ;   2018/05/14 - Sophie M, UMN, initial release
  ;    
  ;-
  nfiles = n_elements(list)
  name = strsplit(list[0],'.',/extract)
  cd, current=currentdir
  DEFAULT, dir, currentdir+'\'
  DEFAULT, plotname, '2dhisto_usb_'+name[0]+'.eps'
  DEFAULT, noplot, 0
  DEFAULT, title, 'USB '+name[0]+' with '+strsplit(string(nfiles),/extract)+' files'

  hist = list()
  ; read all files and create a list of histogram data
  FOR k=0, nfiles-1 DO BEGIN
    f=list[k]
    data = read_data_struct_cal(dir+f)    
    str = 'struct_'+f    
    save,data,file=str
    h=makehist(str,/cmn_med)
    hist.add, h
  ENDFOR

  IF noplot EQ 1 THEN saveplot=0 ELSE BEGIN 
    saveplot=1
    print, 'Will save file ', plotname
  ENDELSE

  make_3dhistoplot, h, saveplot=saveplot, plotname=plotname, title=title, _extra=extra
END