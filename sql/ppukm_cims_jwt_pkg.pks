CREATE OR REPLACE PACKAGE ppukm_cims_jwt_pkg AS
/**************************************************************************
REM Change History Information
REM --------------------------
REM Version   Date         Author           Change Reference / Description
REM -------   -----------  ---------------  ------------------------------------
REM 1.0       23-OCT-2020  Frank Zhang      Initial Creation
REM ***************************************************************************/
FUNCTION get_cims_url_with_token(
                                p_url           IN VARCHAR2,
                                p_mrn           IN VARCHAR2 DEFAULT NULL,
                                p_os_user       IN VARCHAR2 DEFAULT NULL,
                                p_user          IN VARCHAR2 DEFAULT NULL,
                                p_other_params  IN VARCHAR2 DEFAULT NULL,
                                p_issuer        IN VARCHAR2 DEFAULT 'PPUKM',
                                p_signature_key IN VARCHAR2 DEFAULT NULL
                                ) 
RETURN VARCHAR2;


END ppukm_cims_jwt_pkg;