PRO PROCESSEFFICIENCY, KEYWORD, VTH0 = VTH0, BADCH = BADCH





ff=findfile('data*'+keyword+'*')

for i=0, n_elements(ff)-1 do begin
    file=ff[i]
    data=read_data_struct_cal(file)
    str='struct_'+file
    save,data,file=str
    h=makehist(str,/cmn_median)
    print,countrate_simple(str,badch=badch)
endfor



calcefficiency, keyword, vth0=vth0, badch=badch




end
