FUNCTION look4paired_strip_candidates, h, adc2check=adc2check, sigma=sigma

  ;+
  ; :description:
  ;   this function takes a foxsi histogram and return a list of strips that could be touching each other
  ;   to do that, for given adc channels, we compare the values of the strips to the median of the values accross the same asic.
  ;   if we find strips that have values superior to 5 times the median, for all adc channel tested, then we put them in the list to be returned
  ;   we return a list of 4 arrays, one for each asic
  ;   
  ; :input:
  ;   h: foxsi histogram structure (created with makehist) 
  ;
  ; :keyword:
  ;   adc2check: in, intarray, adc values where we are looking for higher values. default is [10, 20, 30]
  ;   sigma:     in, integer,  factor by which median is multiplied to select candidates. default is 5
  ;   
  ; :example:
  ;   h1=makehist(str,/sub)
  ;   print, LOOK4PAIRED_STRIP_CANDIDATES(h1, sigma=3, adc2check=[10,15])
  ;
  ; :history:
  ;   Sophie M, UMN, 2018/05/17: release
  ;-

  ;----------------------------------------
  ; setting default values for the keywords
  ;----------------------------------------

  DEFAULT, adc2check, [10, 20, 30]
  DEFAULT, sigma, 5

  ;----------------------------------------
  ; initialize the variable to be returned
  ;----------------------------------------
  
  candidates = list() ; this will be a four elements list (each element is a list of candidate for the corresponding asic)
  
  ;------------------------------------------
  ; start to look for candidate, asic by asic
  ;------------------------------------------
  
  FOR asic=0, 3 DO BEGIN
    ; initialize
    ;-----------
    cand_asic = list() ; this list will contain the candidates for this asic. Each element of the list will be the candidates selected for a particular ADC value
    ncand = intarr( n_elements(adc2check)) ; this will contain the number of candidates for this asic for each selected ADC values
    ; look for candidates in each ADC values specified by the keyword adc2check
    ;--------------------------------------------------------------------------
    FOR k=0, n_elements(adc2check)-1 DO BEGIN
      channels = reform(h[adc2check[k],*,asic,1]) ; extract the value of one adc channel for all strips (all channels)
      media = median( channels ) ; calculate the median value
      sel = where(channels GT sigma*media, nsel) ; select the strips for which that ADC value is particularly high
      cand_asic.add, sel ; add those strips as candidates for this ADC channel
    ENDFOR
    ; now we will select strips which are candidates in all the ADC channel considered
    ; this step is meant to avoid false positives
    ; ---------------------------------------------------------------------------------    
    final = cand_asic[0] ; we will update final until we have compared all the candidates for all adc values selected
    FOR k=1, n_elements(adc2check)-1 DO BEGIN
      match, final, cand_asic[k], sel1, sel2 ; sel1 contains the subscripts of the values of final that have a match in cand_asic[k]
      final=final[sel1] ;  keep only the elements for which we found a match
    ENDFOR
    ; print some summary
    ;-------------------
    print, 'found ', n_elements(final), ' candidates in asic ', asic
    candidates.add, final ;  add the result of this asic to the list that will be returned
  ENDFOR

  ;------------------
  ; return the result
  ;------------------

  RETURN, candidates ; this is a list of 4 arrays
 
END