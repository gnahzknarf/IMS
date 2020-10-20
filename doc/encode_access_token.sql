declare
    l_jwt varchar2(32767);
begin
    -- Call this over db link to apex database    
    l_jwt := apex_jwt.encode (
                 p_iss           => 'other_app',    -- Issuer : the calling app
                 p_aud           => 'CIMS',         -- Audience: CIMS APEX app
                 p_sub           => 'Frank',     -- User Name
                 p_exp_sec       => 10,             -- Expire in 10 seconds
                 p_other_claims  => '"P6_MRN":'|| apex_json.stringify('TESTING'),  -- MRN                 
                 p_signature_key => sys.utl_raw.cast_to_raw('kYedRDkPvEOJLFFOn66vjiS-pjeCwk7uNX4QbgrhdrnGVb86saIEhvt3CW__CQAPqrHCLFrYo620lbJUo5MHE2Di8Z53lDd_RRyTdeMVhdulECPCY5_yUH3PKxzvNv23iP6knZmYrO1qARiEASphryaGr28PL6nkTl2Tjce4Sbfnbwi7hWl9Wb-9Xia6ICIyklU8aeoQU1tMxxZyDWj37dbWSld155LzkBGAIwlVBM2CPqIwmC22U3TOPL4w-xtyg18AM-Zl3nnWK8XqF-z5yR7lAOT1_11lDYaIcFO71MMknTZhy9gejxVUVL1jMd1FHP6BW5sLcDLMGBIMw10a7g')  -- Secret: a random string agreed between calling app and CIMS APEX app
                );  
   -- URL with access token
   dbms_output.put_line ('http://brisbane.ims.com.au:8080/ords/f?p=103:6&x01='||l_jwt);  
           
end;