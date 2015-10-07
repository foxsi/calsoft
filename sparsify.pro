FUNCTION SPARSIFY, FILE

restore, file

n_evts = n_elements(data)
d = data.data

i = where(d gt 1000)
if i[0] gt -1 then d[i] = 0

for i=long(0), n_evts-1 do begin
	for asic = 0, 3 do begin
		max = max(d[asic,*,i], ind)
		j = where(d[asic,*,i] lt max)
		if j[0] gt -1 then d[asic,j,i] = 0.
	endfor
endfor

i = where(data.common_mode lt 1.)
print, n_elements(i)/4., n_evts

data.data = d

save, data, file = file+'_sparse'

return, 1

END