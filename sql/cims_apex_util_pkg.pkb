CREATE OR REPLACE PACKAGE BODY cims_apex_util_pkg AS
/**************************************************************************
REM Change History Information
REM --------------------------
REM Version   Date         Author           Change Reference / Description
REM -------   -----------  ---------------  ------------------------------------
REM 1.0       18-OCT-2020  Frank Zhang      Initial Creation
REM ***************************************************************************/
    
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

    FUNCTION sentry return boolean
    IS   
      
        l_x01      varchar2(32767);
        l_jwt      apex_jwt.t_token;
        l_jwt_user varchar2(255);
        l_jwt_elts apex_t_varchar2;
    begin
        --
        -- parse JWT payload in X01
        --
        l_x01 := v('APP_AJAX_X01');
        apex_debug.trace('X01=%s', l_x01);
        if l_x01 like '%.%.%' then
            begin
                l_jwt := apex_jwt.decode (
                                            p_value         => l_x01,
                                            p_signature_key => sys.utl_raw.cast_to_raw('XVTFBXHqwG7QqOihDo5YvPaHu87KZOIr') 
                                            );                
                apex_debug.trace('JWT payload=%s', l_jwt.payload);
                --
                apex_jwt.validate (
                                    p_token => l_jwt,
                                    p_iss   => 'other_app',
                                    p_aud   => 'CIMS',
                                    p_leeway_seconds => 60 );
                
                apex_debug.trace('...validated');
                --
                apex_json.parse (p_source => l_jwt.payload );
                l_jwt_user := apex_json.get_varchar2('sub');
            exception 
                when others then
                    apex_debug.trace('...error: %s', sqlerrm);
            end;
        end if;
        --
        -- if not logged in yet:
        -- - log in with JWT user if JWT given
        -- - or trigger custom invalid session/login flow
        --
        if apex_authentication.is_public_user then
            if l_jwt_user is not null then
                apex_authentication.post_login (p_username => l_jwt_user );
            else
                return false;
            end if;
        elsif apex_application.g_user <> l_jwt_user then
            apex_debug.trace('...login user %s does not match JWT user %s',
                            apex_application.g_user,
                            l_jwt_user );
            return false;
        end if;
        --
        -- if JWT given, assign additional parameters to items
        --
        if l_jwt_user is not null then
            l_jwt_elts := apex_json.get_members('.');
            for i in 1 .. l_jwt_elts.count loop
                if l_jwt_elts(i) like 'P%' then
                    apex_debug.trace('...setting %s', l_jwt_elts(i));
                    apex_util.set_session_state (
                        p_name  => l_jwt_elts(i),
                        p_value => apex_json.get_varchar2(l_jwt_elts(i)) );
                end if;
            end loop;
        end if;
        return true;      
    end;
END cims_apex_util_pkg;