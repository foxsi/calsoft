PRO CALCEFFICIENCY, KEYWORD, VTH0 = VTH0, BADCH = BADCH



files=findfile('struct*'+keyword+'*')
vth=findgen(n_elements(files))+VTH0
fefficiency, vth=vth, files=files, badch=badch






end
