CREATE OR REPLACE PACKAGE BODY ims_jwt_encode_pkg AS
/*******************************************************************************
REM
REM (C) Copyright - Integrated Medical Technology Pty Ltd. 1993 - 2020. All rights reserved.
REM 
REM
REM Change History Information
REM --------------------------
REM Version   Date         Author           Change Reference / Description
REM -------   -----------  ---------------  ------------------------------------
REM 1.0       23-OCT-2020  Frank Zhang      Initial Creation
REM ***************************************************************************/
--
FUNCTION encode_base64(p_string IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    return translate((replace(utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(p_string))),'=')), unistr('+/=\000a\000d'), '-_');
END encode_base64;
--
FUNCTION encrypt(p_string           IN VARCHAR2,
                 p_signature_key    IN VARCHAR2 DEFAULT NULL
                 ) 
RETURN VARCHAR2 IS
    l_set_key VARCHAR2(500); 
BEGIN 
    IF p_signature_key IS NULL THEN
      l_set_key := '-5qMahjEc6f2D_hH-NjQMvTibZaVRVDNrG2WX14Rp_4e9UlFELoXq3VpTVNi1yrI9nhVEX6Q25OMAF4q2L2l2zJeV0nJak3Fgo92CmqnfbvsQY1emqojZOhbcBxXP6LhWU2gXNvQZBRCoBOHiJjMsBKqrt2Q5F1e7hQKsDd3TzbnprbbpGtppqXcnWhuk2496hED21zuxN9Sgh_9UFTCiaKV9pO_CXTYDfjD5oGfHy_66DqBk9SNpoI-XPvzGEpUq0URRjIg5S7fdcG7AEIjO9jArhKnC_1zInugGH5S7TWNiL70VGdhtd0DwJCjbV9vGytpTgt3Xuw1fTVOXu20-A';
    ELSE
      l_set_key := p_signature_key;
    END IF;
    --    
    return encode_base64(utl_raw.cast_to_varchar2(sys.dbms_crypto.mac(utl_raw.cast_to_raw(p_string), sys.dbms_crypto.HMAC_SH256, utl_raw.cast_to_raw(l_set_key))));
END encrypt;
--
FUNCTION get_issue_at RETURN NUMBER IS
BEGIN 
    --RETURN (SYSDATE - to_date('01/01/1970 00:00:00','DD/MM/YYYY HH24:Mi:SS'))*24*60*60;
    RETURN (CAST((SYSTIMESTAMP AT TIME ZONE 'UTC') AS DATE) - DATE'1970-01-01') * 24*60*60;
END get_issue_at;
--
FUNCTION get_cims_url_with_token(
                                p_url           IN VARCHAR2,
                                p_mrn           IN VARCHAR2 DEFAULT NULL,
                                p_os_user       IN VARCHAR2 DEFAULT NULL,
                                p_user          IN VARCHAR2 DEFAULT NULL,
                                p_other_params  IN VARCHAR2 DEFAULT NULL,
                                p_issuer        IN VARCHAR2 DEFAULT 'PPUKM',
                                p_signature_key IN VARCHAR2 DEFAULT NULL
                                ) 
RETURN VARCHAR2 IS
    l_header                VARCHAR2(150);
    l_payload               VARCHAR2(4000);
    l_signature             VARCHAR2(4000);
    l_encoded_header        VARCHAR2(4000);
    l_encoded_payload       VARCHAR2(4000);
    l_encoded_signature     VARCHAR2(4000);
    l_token                 VARCHAR2(4000);
    l_default_audience      VARCHAR2(50) := 'CIMS';
BEGIN
    -- 1. Header
    l_header := '{ "alg": "HS256", "typ": "JWT"}';
    -- 2. Payload
    l_payload := '{';
        -- Standard/registered claims
        -- Issuer
        IF p_issuer IS NOT NULL THEN
            l_payload := l_payload || ' "iss": "' || p_issuer ||'"'; 
        END IF;
        -- Subject
        --IF p_user IS NOT NULL THEN
        --    l_payload := l_payload || ', "sub": "'||p_issuer ||' access token to '|| l_default_audience||'"';
        --END IF;   
        -- Audience
        l_payload := l_payload || ', "aud": "'||l_default_audience||'"';
        -- Issue At
        l_payload := l_payload || ', "iat": ' || ROUND(get_issue_at);
        -- Expiration 300 seconds
         l_payload := l_payload || ', "exp": '|| ROUND(get_issue_at + 300); 
        
        -- 
        -- Other/Private claims
        IF p_mrn IS NOT NULL THEN 
            l_payload := l_payload || ', "p_mrn": "'|| p_mrn ||'"';
        END IF;
        --
        IF p_os_user IS NOT NULL THEN
            l_payload := l_payload || ', "p_os_user": "'|| p_os_user ||'"';
        END IF;
        --
        IF p_user IS NOT NULL THEN
            l_payload := l_payload || ', "p_user": "'|| p_user ||'"';
        END IF;
        --
          --
        IF p_other_params IS NOT NULL THEN
            l_payload := l_payload || ', '|| p_other_params ;
        END IF;
    l_payload := l_payload || '}';

    -- Encode header and payload
    l_encoded_header    := encode_base64(l_header);
    l_encoded_payload   := encode_base64(l_payload);

    -- Generate signature by encrypting header and payload
    l_signature := l_encoded_header || '.' || l_encoded_payload;
    l_encoded_signature := encrypt( p_string        => l_signature, 
                                    p_signature_key => p_signature_key);
    --
    l_token := l_encoded_header || '.' || l_encoded_payload || '.' || l_encoded_signature;
    --
    IF p_url IS NULL THEN 
        RETURN l_token;
    ELSE     
        return p_url||'&x01=' || l_token;
    END IF;
END get_cims_url_with_token;

END ims_jwt_encode_pkg;