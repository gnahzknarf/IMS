CREATE OR REPLACE PACKAGE BODY cims_apex_util_pkg AS
    /*******************************************************************************************
    REM
    REM (C) Copyright - Integrated Medical Technology Pty Ltd. 1993 - 2020. All rights reserved.
    REM 
    REM
    REM Change History Information
    REM --------------------------
    REM Version   Date         Author           Change Reference / Description
    REM -------   -----------  ---------------  ------------------------------------
    REM 1.0       18-OCT-2020  Frank Zhang      Initial Creation
    REM 
    *******************************************************************************************/
    
    /***************************************************************************************************************************
    ** FUNCTION: log_error
    ** This FUNCTION is used to populate custom table CIMS_APEX_ERROR_LOGS, it is called in cims_apex_ctl_pkg for error logging 
    ***************************************************************************************************************************/
    FUNCTION  log_error (p_error in apex_error.t_error )
    RETURN NUMBER IS        
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_log_id                    NUMBER;        
        l_is_internal_error         VARCHAR2(1);
        l_is_common_runtime_error   VARCHAR2(1);
    BEGIN        
        l_is_internal_error := case p_error.is_internal_error when TRUE then 'Y' when FALSE then 'N' else NULL end;
        l_is_common_runtime_error := case p_error.is_common_runtime_error when TRUE then 'Y' when FALSE then 'N' else NULL end;

        INSERT INTO CIMS_APEX_ERROR_LOGS(
            --log_id                 ,
            message                  ,
            additional_info          ,
            display_location         ,
            association_type         ,
            page_item_name           ,
            region_id                ,
            column_alias             ,
            row_num                  ,
            apex_error_code          ,
            is_internal_error        ,
            is_common_runtime_error  ,
            ora_sqlcode              ,
            ora_sqlerrm              ,
            error_backtrace          ,
            error_statement          ,
            component_name           ,
            component_type           
        )
        values(
            p_error.message,
            p_error.additional_info,
            p_error.display_location,
            p_error.association_type,
            p_error.page_item_name,
            p_error.region_id,
            p_error.column_alias,
            p_error.row_num,
            p_error.apex_error_code,
            l_is_internal_error,
            l_is_common_runtime_error,
            p_error.ora_sqlcode,
            p_error.ora_sqlerrm,
            p_error.error_backtrace,
            p_error.error_statement,
            p_error.component.name,
            p_error.component.type
        ) returning log_id into l_log_id;

        COMMIT;

        return l_log_id;
    EXCEPTION
        when others then
            return null;        
    END log_error;
    --
    /***************************************************************************************************************************
    ** FUNCTION: sentry
    ** This FUNCTION is called during authentication process, to decode and validate the JWT token passed in the URL
    ** After validation, application items are set with parameters in the token
    ***************************************************************************************************************************/
    FUNCTION sentry RETURN BOOLEAN
    IS   
      
        l_x01           VARCHAR2(32767);
        l_jwt           apex_jwt.t_token;
        l_jwt_user      VARCHAR2(255);
        l_jwt_osuser    VARCHAR2(255);
        l_jwt_mrn       VARCHAR2(255);
        l_session       NUMBER;
        l_url           VARCHAR2(4000); 
        l_default_key   VARCHAR2(4000):='-5qMahjEc6f2D_hH-NjQMvTibZaVRVDNrG2WX14Rp_4e9UlFELoXq3VpTVNi1yrI9nhVEX6Q25OMAF4q2L2l2zJeV0nJak3Fgo92CmqnfbvsQY1emqojZOhbcBxXP6LhWU2gXNvQZBRCoBOHiJjMsBKqrt2Q5F1e7hQKsDd3TzbnprbbpGtppqXcnWhuk2496hED21zuxN9Sgh_9UFTCiaKV9pO_CXTYDfjD5oGfHy_66DqBk9SNpoI-XPvzGEpUq0URRjIg5S7fdcG7AEIjO9jArhKnC_1zInugGH5S7TWNiL70VGdhtd0DwJCjbV9vGytpTgt3Xuw1fTVOXu20-A';
        l_default_iss   VARCHAR2(50):= 'PPUKM';
    BEGIN    
        APEX_DEBUG.ENABLE(apex_debug.c_log_level_warn);
        
        -- If already logged in, return true;
        if apex_application.g_user <> 'nobody' then
            return true;
        end if;

        --
        -- Get JWT Token in X01
        --
        l_x01 := v('APP_AJAX_X01');
        apex_debug.warn('CIMS JWT Token=%s', l_x01);        
        --
        -- Decode and Validate JWT Token
        --
        IF l_x01 LIKE '%.%.%' THEN
            BEGIN
                l_jwt := apex_jwt.decode (
                                            p_value         => l_x01,
                                            p_signature_key => sys.utl_raw.cast_to_raw(l_default_key) 
                                        );                
                apex_debug.warn('CIMS JWT payload=%s', l_jwt.payload);
                --
                apex_jwt.validate (
                                    p_token => l_jwt,
                                    p_iss   => l_default_iss,
                                    p_aud   => 'CIMS',
                                    p_leeway_seconds => 300 );
                
                apex_debug.warn('CIMS ...validated');

            EXCEPTION 
                WHEN OTHERS THEN
                    apex_debug.warn('CIMS Unable to validate JTW Token...error: %s', sqlerrm);
                    RETURN FALSE;
            END;
        ELSE
            apex_debug.warn('CIMS Incorrect JTW Token format...');
                    
            RETURN FALSE;
        END IF;
        --
        -- Token is valid, get additional parameters
        -- This procedure parses a JSON-formatted p_source and puts the members into the package global g_values
        apex_json.parse (p_source => l_jwt.payload );
        
        -- g_values is a table of records, value can be retrieved simialar to name value pair
        l_jwt_user      := apex_json.get_varchar2(p_path=>'p_user');
        l_jwt_osuser    := apex_json.get_varchar2(p_path=>'p_os_user');
        l_jwt_mrn       := apex_json.get_varchar2(p_path=>'p_mrn');
        apex_debug.warn('CIMS jwt_user=%s, jwt_os_user=%s, jwt_mrn=%s...',l_jwt_user,l_jwt_osuser,l_jwt_mrn);
        
        -- is there already a session?
        l_session := APEX_CUSTOM_AUTH.GET_SESSION_ID_FROM_COOKIE;
        
        apex_debug.warn('CIMS l_session=%s...',l_session);

                
        IF l_session IS NOT NULL THEN
            -- test if the session is still valid and get a new session id, if not valid
            IF NOT APEX_CUSTOM_AUTH.IS_SESSION_VALID THEN                
                l_session := APEX_CUSTOM_AUTH.GET_NEXT_SESSION_ID;
                apex_debug.warn('CIMS l_session is not valid. got new ssion=%s...',l_session);
            ELSE
                apex_debug.warn('CIMS l_session is still valid. ');
            END IF;

            -- initialize the session
            APEX_CUSTOM_AUTH.post_login (p_uname => l_jwt_user,p_session_id => l_session );
            --APEX_CUSTOM_AUTH.DEFINE_USER_SESSION (l_jwt_user, l_session);   
        ELSE
            -- no session in cookie found
            apex_authentication.post_login (p_username => l_jwt_user );
        END IF;
        
        -- Set Application Items
        APEX_UTIL.SET_SESSION_STATE('G_OS_USER',l_jwt_osuser);
        APEX_UTIL.SET_SESSION_STATE('G_MRN',l_jwt_mrn);
        
        -- Redirect to Page 6        
        IF l_jwt_mrn IS NOT NULL THEN
            l_url := APEX_PAGE.GET_URL (
                                        p_page   => 6,
                                        p_items  => 'P6_MRN',
                                        p_values => l_jwt_mrn );
            apex_util.redirect_url(l_url);
        END IF;
        --
        APEX_DEBUG.DISABLE();
        return true;      
    end sentry;
    --
END cims_apex_util_pkg;