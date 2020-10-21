CREATE OR REPLACE PACKAGE cims_apex_ctl_pkg AS
/**************************************************************************
REM Change History Information
REM --------------------------
REM Version   Date         Author           Change Reference / Description
REM -------   -----------  ---------------  ------------------------------------
REM 1.0       30-SEP-2020  Frank Zhang      Initial Creation
REM ***************************************************************************/
    PROCEDURE cb_populate_cumulative_collection(
        p_req_key    IN  NUMBER,
        p_rqt_key    IN  NUMBER,
        p_date_from  IN  VARCHAR2,
        p_date_to    IN  VARCHAR2
    );
	--
	FUNCTION  apex_error_handler (p_error in apex_error.t_error )
    return apex_error.t_error_result;
    --
    PROCEDURE CB_GET_REPORT(p_req_key IN NUMBER,
                            p_rqt_key IN NUMBER);
END cims_apex_ctl_pkg;