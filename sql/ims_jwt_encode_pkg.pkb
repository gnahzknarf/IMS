CREATE OR REPLACE PACKAGE BODY ims_jwt_encode_pkg AS
/*******************************************************************************************
REM
REM (C) Copyright - Integrated Medical Technology Pty Ltd. 1993 - 2020. All rights reserved.
REM 
REM
REM Change History Information
REM --------------------------
REM Version   Date         Author           Change Reference / Description
REM -------   -----------  ---------------  ------------------------------------
REM 1.0       23-OCT-2020  Frank Zhang      Initial Creation
REM ****************************************************************************************/
--
C_SECONDS_IN_DAY CONSTANT PLS_INTEGER := 86400;
--
FUNCTION TO_SECONDS_SINCE_EPOCH (P_TSTZ IN TIMESTAMP WITH TIME ZONE )
    RETURN PLS_INTEGER
IS
BEGIN
    IF P_TSTZ IS NULL THEN
        RETURN NULL;
    ELSE
        RETURN (CAST((P_TSTZ AT TIME ZONE 'UTC') AS DATE) - DATE'1970-01-01') * C_SECONDS_IN_DAY;
    END IF;
END TO_SECONDS_SINCE_EPOCH;
-- 
FUNCTION TO_URL (P_STR IN VARCHAR2 )
    RETURN VARCHAR2
IS
BEGIN
    RETURN TRANSLATE (P_STR, UNISTR('+/=\000a\000d'), '-_' );
END TO_URL;
--
FUNCTION BASE64URL_ENCODE (P_STR IN VARCHAR2 )
    RETURN VARCHAR2
IS
BEGIN
    RETURN TO_URL (
                SYS.UTL_RAW.CAST_TO_VARCHAR2 (
                    SYS.UTL_ENCODE.BASE64_ENCODE (
                        SYS.UTL_RAW.CAST_TO_RAW(P_STR) )));
END BASE64URL_ENCODE;
--
FUNCTION GET_HS256_SIGNATURE (
                                P_HEADER_AND_PAYLOAD IN VARCHAR2,
                                P_SIGNATURE_KEY      IN RAW )
    RETURN VARCHAR2
IS
    l_signature_key VARCHAR2(32767);
BEGIN
    IF p_signature_key IS NULL THEN
      l_signature_key := SYS.UTL_RAW.CAST_TO_RAW('-5qMahjEc6f2D_hH-NjQMvTibZaVRVDNrG2WX14Rp_4e9UlFELoXq3VpTVNi1yrI9nhVEX6Q25OMAF4q2L2l2zJeV0nJak3Fgo92CmqnfbvsQY1emqojZOhbcBxXP6LhWU2gXNvQZBRCoBOHiJjMsBKqrt2Q5F1e7hQKsDd3TzbnprbbpGtppqXcnWhuk2496hED21zuxN9Sgh_9UFTCiaKV9pO_CXTYDfjD5oGfHy_66DqBk9SNpoI-XPvzGEpUq0URRjIg5S7fdcG7AEIjO9jArhKnC_1zInugGH5S7TWNiL70VGdhtd0DwJCjbV9vGytpTgt3Xuw1fTVOXu20-A');
    ELSE
      l_signature_key := p_signature_key;
    END IF;
    --
    RETURN TO_URL (
                SYS.UTL_RAW.CAST_TO_VARCHAR2 (
                    SYS.UTL_ENCODE.BASE64_ENCODE (
                                                    ims_util_crypto.mac (
                                                    P_SRC       => SYS.UTL_RAW.CAST_TO_RAW(P_HEADER_AND_PAYLOAD),
                                                    p_typ       => ims_util_crypto.gc_hmac_sh256,
                                                    P_KEY       => l_signature_key)
                                                )
                                            )
                    );
END GET_HS256_SIGNATURE;
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
    l_header                VARCHAR2(32767);
    l_payload               VARCHAR2(32767);
    l_result                VARCHAR2(32767);
    l_signature             VARCHAR2(32767);
    l_comma                 BOOLEAN := FALSE;
    --
    l_token                 VARCHAR2(4000);
    l_default_audience      VARCHAR2(50) := 'CIMS';
    --
    PROCEDURE PUSH_RAW (
        P_NAME IN VARCHAR2,
        P_VALUE IN VARCHAR2 )
    IS
    BEGIN
        IF P_VALUE IS NOT NULL THEN
            L_PAYLOAD := L_PAYLOAD||
                        CASE WHEN L_COMMA THEN ',' END||
                        '"'||P_NAME||'":'||P_VALUE;
            L_COMMA := TRUE;
        END IF;
    END PUSH_RAW;

    PROCEDURE PUSH_STR (
        P_NAME IN VARCHAR2,
        P_VALUE IN VARCHAR2 )
    IS
    BEGIN
        IF P_VALUE IS NOT NULL THEN
            L_PAYLOAD := L_PAYLOAD||
                        CASE WHEN L_COMMA THEN ',' END||
                        '"'||P_NAME||'":"'||P_VALUE||'"';
            L_COMMA := TRUE;
        END IF;
    END PUSH_STR;

    
BEGIN
    -- 1. HEADER
    l_header := '{ "alg": "HS256", "typ": "JWT"}';
    l_header := BASE64URL_ENCODE(l_header);
    -- 2. Payload
    l_payload := '{';
        -- Standard/registered claims
        -- Issuer
        PUSH_STR('iss', p_issuer);
        -- Subject
        --
        -- Audience
        PUSH_STR('aud', l_default_audience);
        -- Issue At
        PUSH_RAW('iat', TO_SECONDS_SINCE_EPOCH(SYSTIMESTAMP));
        --
        -- Expiration 300 seconds
        PUSH_RAW('iat', TO_SECONDS_SINCE_EPOCH(SYSTIMESTAMP) + 300 );        
        -- 
        -- Other/Private claims
        PUSH_STR('p_mrn', p_mrn);
        PUSH_STR('p_os_user', p_os_user);
        PUSH_STR('p_user', p_user);
        --
        IF p_other_params IS NOT NULL THEN
            l_payload := l_payload || CASE WHEN L_COMMA THEN ',' END || p_other_params;
        END IF;
    l_payload := l_payload || '}';

    l_payload := BASE64URL_ENCODE(l_payload);
    
    l_result  := l_header||'.'||l_payload;

    -- Generate signature by encrypting header and payload
    l_signature := GET_HS256_SIGNATURE (
                                        P_HEADER_AND_PAYLOAD => l_result,
                                        P_SIGNATURE_KEY      => P_SIGNATURE_KEY );

    --
    l_token := l_result||'.'||l_signature;
    --
    IF p_url IS NULL THEN 
        RETURN l_token;
    ELSE     
        return p_url||'&x01=' || l_token;
    END IF;
END get_cims_url_with_token;

END ims_jwt_encode_pkg;