;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION COUNTRATE_SIMPLE, FILE, BADCH=BADCH, STOP = STOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  restore,file


  n_evts = n_elements(data)


    hitch=0
    counts=long(0)
    livetime=double(0)
    edepp=float(0)




    for evt = long(0)+long(n_evts/10.), n_evts-1 do begin
        

        hitchnump=0
        
        if total(data[evt].packet_error) lt 10 and min(data[evt].time[*]) eq max(data[evt].time[*]) then begin



                data2=data[evt].data[2,*]*(1-badch[2,*])
                data3=data[evt].data[3,*]*(1-badch[3,*])
                edep2max=max(data2)
                edep3max=max(data3)
                if n_elements(where(data2 lt edep2max)) gt 2 and n_elements(where(data3 lt edep3max)) gt 2 then begin
                    edep2max2=max(data2[where(data2 lt edep2max)])
                    edep3max2=max(data3[where(data3 lt edep3max)])
                    edep2=edep2max-edep2max2
                    edep3=edep3max-edep3max2
                    
                livetime+=min(data[evt].time[*])
                    
                    if edep2 gt 20 and edep2 lt 100 and edep3 lt 10 then counts+=1
                    if edep3 gt 20 and edep3 lt 100 and edep2 lt 10 then counts+=1
                endif



                    
        endif
    endfor

    print, 'counts = ', counts
  rate=[counts/(livetime/1.0e6),sqrt(counts)/(livetime/1.0e6)]
  return, rate
  
END
