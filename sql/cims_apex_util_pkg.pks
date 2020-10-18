CREATE OR REPLACE PACKAGE cims_apex_util_pkg AS
/**************************************************************************
REM Change History Information
REM --------------------------
REM Version   Date         Author           Change Reference / Description
REM -------   -----------  ---------------  ------------------------------------
REM 1.0       18-OCT-2020  Frank Zhang      Initial Creation
REM ***************************************************************************/

FUNCTION log_error(p_error in apex_error.t_error)
RETURN NUMBER;

END cims_apex_util_pkg;