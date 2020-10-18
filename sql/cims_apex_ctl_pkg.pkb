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
END cims_apex_util_pkg;