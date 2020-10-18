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
    return number IS        
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_log_id    number;        
    BEGIN
        l_reference_id := CIMS_APEX_ERROR_LOG_ID.nextval
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
            p_error.asociation_type,
            p_error.page_item_name,
            p_error.region_id,
            p_error.column_alias,
            p_error.row_num,
            p_error.apex_error_code,
            (case when p_error.is_internal_error then 'Y' else 'N' end),
            (case when p_error.is_common_runtime_error then 'Y' else 'N' end),
            p_error.ora_sqlcode,
            p_error.ora_sqlerrm,
            p_error.error_backtrace,
            p_error.error_statement,
            p_error.component_name
            p_error.component_type
        ) returning log_id into l_log_id;

        COMMIT;

        return l_log_id;
    exception
        when others then
            return null;        
    END apex_error_handler;
END cims_apex_ctl_pkg;