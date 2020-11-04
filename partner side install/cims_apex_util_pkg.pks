CREATE OR REPLACE PACKAGE cims_apex_util_pkg AS
/*******************************************************************************
REM
REM (C) Copyright - Integrated Medical Technology Pty Ltd. 1993 - 2020. All rights reserved.
REM 
REM
REM Change History Information
REM --------------------------
REM Version   Date         Author           Change Reference / Description
REM -------   -----------  ---------------  ------------------------------------
REM 1.0       18-OCT-2020  Frank Zhang      Initial Creation
REM ***************************************************************************/

FUNCTION log_error(p_error in apex_error.t_error)
RETURN NUMBER;

FUNCTION sentry return boolean;
--
END cims_apex_util_pkg;