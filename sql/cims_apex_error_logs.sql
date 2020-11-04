CREATE SEQUENCE CIMS_APEX_ERROR_LOG_ID;
/

CREATE TABLE CIMS_APEX_ERROR_LOGS(
/*******************************************************************************
REM
REM (C) Copyright - Integrated Medical Technology Pty Ltd. 1993 - 2020. All rights reserved.
REM 
REM
REM ***************************************************************************/
    log_id                   number DEFAULT ON NULL CIMS_APEX_ERROR_LOG_ID.nextval primary key,
    message                  varchar2(4000),     /* Error message which will be displayed */
    additional_info          varchar2(4000),     /* Only used for display_location ON_ERROR_PAGE to display additional error information */
    display_location         varchar2(40),       /* Use constants "used for display_location" below */
    association_type         varchar2(40),       /* Use constants "used for asociation_type" below */
    page_item_name           varchar2(255),      /* Associated page item name */
    region_id                number,             /* Associated tabular form region id of the primary application */
    column_alias             varchar2(255),      /* Associated tabular form column alias */
    row_num                  integer,            /* Associated tabular form row */
    apex_error_code          varchar2(255),      /* Contains the system message code if it's an error raised by APEX */
    is_internal_error        varchar2(1),        /* Set to Y if it's a critical error raised by the APEX engine, like an invalid SQL/PLSQL statements, ... Internal Errors are always displayed on the Error Page */
    is_common_runtime_error  varchar2(1),        /* Y for internal authorization, session and session state errors that normally should not be masked by an error handler */
    ora_sqlcode              number,             /* SQLCODE on exception stack which triggered the error, NULL if the error was not raised by an ORA error */
    ora_sqlerrm              varchar2(4000),     /* SQLERRM which triggered the error, NULL if the error was not raised by an ORA error */
    error_backtrace          varchar2(4000),     /* Output of sys.dbms_utility.format_error_backtrace or sys.dbms_utility.format_call_stack */
    error_statement          varchar2(4000),     /* Statement that was parsed when the error occurred - only suitable when parsing caused the error */
    component_name           varchar2(255),      /* Component name which has been processed when the error occurred */
    component_type           varchar2(255)       /* Component type which has been processed when the error occurred */
);
/