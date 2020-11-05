CREATE OR REPLACE PACKAGE BODY cims_apex_ctl_pkg AS
/******************************************************************************************
REM
REM (C) Copyright - Integrated Medical Technology Pty Ltd. 1993 - 2020. All rights reserved.
REM 
REM
REM Change History Information
REM --------------------------
REM Version   Date         Author           Change Reference / Description
REM -------   -----------  ---------------  ------------------------------------
REM 1.0       30-SEP-2020  Frank Zhang      Initial Creation
REM 
*******************************************************************************************/


    PROCEDURE print_log(
        p_log_message IN VARCHAR2
    )IS
    BEGIN
        --APEX_DEBUG.MESSAGE (p_message => 'GJ - '||p_log_message);
        APEX_DEBUG.INFO  (p_message => 'GJ - '||p_log_message);
    END print_log;   
    
    
    /***************************************************************************************************************************
    ** PROCEDURE: cb_set_cumulative_coll
    ** This procedure is used to populate apex_collections with cumulative results based on date range.
    ** The reason do to this is because the number of columns is unknown at design time. and APEX reports components need to know
    ** at design time. the limitation of this method is that apex_collections only allows 50 VARCHAR2 columns
    ***************************************************************************************************************************/
    PROCEDURE cb_set_cumulative_coll(
        p_req_key    IN  NUMBER,
        p_rqt_key    IN  NUMBER,
        p_date_from  IN  VARCHAR2,
        p_date_to    IN  VARCHAR2
    )
    IS
        v_seq               NUMBER DEFAULT 0;
        v_sql_stmt1         VARCHAR2(3200);    
        v_sql_stmt2         VARCHAR2(2000);    
        v_sql               VARCHAR2(4000);   
        cur_sql_col_hdr     SYS_REFCURSOR;
        col_hdr_sql_stmt    VARCHAR2(2000) := 'SELECT * FROM APEX_COLLECTIONS  WHERE collection_name = ''CUMULATIVE_COL_HEADER'' ORDER BY C002';
        
        
        CURSOR cur_column_headers IS
            WITH
            apex_params AS(
                SELECT  p_req_key AS REQ_KEY,
                        p_rqt_key AS RQT_KEY,
                        TO_DATE(p_date_from,'DD/MM/YYYY') AS DATE_FROM,
                        TO_DATE(p_date_to,'DD/MM/YYYY') AS DATE_TO                        
                FROM dual    
            ),test_list AS (
                SELECT  /*+ materialize */
                        DISTINCT td.td_name,req.pat_key
                FROM    ilms5.request@apex_link REQ,
                        ilms5.request_test@apex_link rqt,
                        test_detail@apex_link td,
                        apex_params params
                WHERE   req.req_key = rqt.req_key
                AND     rqt.td_key = td.td_key
                AND     req.req_key = params.REQ_KEY
                AND     rqt.rqt_key = params.RQT_KEY
            )                
            SELECT DISTINCT 
                    req.req_name,
                    req.req_relev_date,
					'<b>'||req.req_name||'</b>' || '</br>'||
					TO_CHAR(req.req_relev_date,'DD/MM/YYYY') || '</br>'||
					TO_CHAR(req.req_relev_date,'HH24:MI') 
					AS HEADER_DSP
            FROM test_detail@apex_link td,
                 test_list tl,
                 request@apex_link REQ,
                 request_test@apex_link rqt,
                 apex_params params
            WHERE tl.td_name = td.td_name
            AND   tl.pat_key = req.pat_key
            AND   req.req_key = rqt.req_key
            AND   rqt.td_key = td.td_key
            AND   TRUNC(req.req_relev_date) BETWEEN params.DATE_FROM AND params.DATE_TO
            AND   EXISTS(SELECT 1 FROM request_test@apex_link rqt1 WHERE rqt1.req_key = req.req_key AND TRIM(rqt1.rqt_desc) IS NOT NULL )
            ORDER BY req.req_relev_date ASC
                ;            
    BEGIN
        print_log('Begin cb_populate_cumulative_collection');
        -- 1. Build a colleciton of column names
        APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION (p_collection_name => 'CUMULATIVE_COL_HEADER');     
        v_seq := 3; -- starts from 4 as the first 3 are td_name, unit, range
        FOR rec IN cur_column_headers LOOP            
            EXIT WHEN v_seq = 45; -- only allow up to 45 cols
            v_seq := v_seq + 1;
            APEX_COLLECTION.ADD_MEMBER (p_collection_name  => 'CUMULATIVE_COL_HEADER',
                                        p_c001=> rec.req_name,
                                        p_C002=> 'C'||LPAD(v_seq,3,'0'),
										p_C003=> rec.HEADER_DSP
                                        );
        END LOOP;        
        
        -- 2. put column names in a string
        FOR REC IN (SELECT C001,C002 FROM APEX_COLLECTIONS  WHERE collection_name = 'CUMULATIVE_COL_HEADER' ORDER BY C002) LOOP
            IF v_sql_stmt2 IS NULL THEN
              v_sql_stmt2 := ''''||rec.C001 ||''' '|| rec.C002;
            ELSE
              v_sql_stmt2 := v_sql_stmt2||', '''||rec.C001 ||''' '|| rec.C002;
            END IF;
        END LOOP;
        --
        v_sql_stmt1 := 
                    'WITH apex_params AS(SELECT  '||
                                p_req_key ||' AS REQ_KEY,'||
                                p_rqt_key ||' AS RQT_KEY,'||            
                                'TO_DATE('''||p_date_from  ||''',''DD/MM/YYYY'') AS DATE_FROM, '||
                                'TO_DATE('''||p_date_to ||''',''DD/MM/YYYY'') AS DATE_TO '||
                        ' FROM dual'    
                    ||q'[),request_tests AS (
                        SELECT 
                                /*+ materialize */
                                req.req_key,
                                req.pat_key,
                                req.req_relev_date,
                                rqt.rqt_key,
                                rqt.parent_rqt_key,
                                rqt.rqt_rank,
                                rqt.td_key,
                                rqt.rqt_desc,
                                rqt.abn_key,
                                rqt.ref_key
                        FROM    ilms5.request@apex_link REQ,
                                ilms5.request_test@apex_link rqt,
                                apex_params params
                        WHERE   req.req_key = rqt.req_key
                        AND     req.req_key = params.REQ_KEY

                    ),
                    hierarchical_rqt AS (
                        SELECT  /*+ materialize */ rt.*
                        FROM    request_tests rt,
                                apex_params params
                        START WITH parent_rqt_key IS NULL AND rt.rqt_key = params.rqt_key
                        CONNECT BY prior rt.req_key = rt.req_key 
                               AND prior rt.rqt_key = rt.parent_rqt_key
                        --order siblings by rt.rqt_key DESC
                    ), test_list AS(
                    SELECT  DISTINCT td.test_key,hrqt.pat_key
                    FROM    hierarchical_rqt hrqt,
                            test_detail@apex_link td
                    WHERE   hrqt.td_key = td.td_key
                    ), results_raw AS(   
                    SELECT td.td_name,
                           RPAD( NVL((SELECT TRIM(abn.abn_text_icon) FROM ilms5.abnormality@apex_link abn WHERE abn.abn_key = rqt.abn_key),' '),3,' ')|| rqt.rqt_desc AS rqt_desc,    
                           req.req_name,
                           (SELECT ref_report FROM ilms5.reference@apex_link WHERE ref_key = rqt.ref_key AND td_key = td.td_key) AS RANGE,
                           (SELECT tu.tu_name FROM ilms5.test_unit@apex_link tu WHERE tu.tu_key = td.tu_key) AS UNIT
                    FROM test_detail@apex_link td,
                         test_list tl,
                         request@apex_link REQ,
                         request_test@apex_link rqt,
                         apex_params params
                    WHERE tl.test_key = td.test_key
                    AND   tl.pat_key = req.pat_key
                    AND   req.req_key = rqt.req_key
                    AND   rqt.td_key = td.td_key
                    AND   (SELECT COUNT(*) FROM request_test@apex_link rqt1 WHERE rqt1.req_key = req.req_key AND rqt1.parent_rqt_key = rqt.rqt_key) = 0
                    AND   TRUNC(req.req_relev_date) BETWEEN params.DATE_FROM AND params.DATE_TO
                    AND   TRIM(rqt.rqt_desc) IS NOT NULL
                    )
                    ]';
                    
                    
        v_sql:= v_sql_stmt1||q'[
            SELECT * FROM results_raw
             pivot (  MAX (rqt_desc)
                      FOR req_name IN (]'||

            v_sql_stmt2

                      ||q'[)
                )
            --ORDER BY TD_NAME;
            ]';    
        --
        APEX_COLLECTION.CREATE_COLLECTION_FROM_QUERY(p_collection_name      => 'CUMULATIVE_VIEW',
                                                     p_query                => v_sql, 
                                                     p_truncate_if_exists   => 'YES');
        -- Prepare output
        OPEN cur_sql_col_hdr FOR col_hdr_sql_stmt;
        apex_json.open_object;
        apex_json.write('success', true);
        apex_json.write('message', 'cb_populate_cumulative_collection completed.');
        --
        apex_json.write('column_headers',cur_sql_col_hdr);
        apex_json.close_object;    
        print_log('End cb_set_workbench_results');
    EXCEPTION
        WHEN others THEN
            print_log('Error in cb_populate_cumulative_collection. '||SQLERRM);
            apex_json.open_object;
            apex_json.write('success', false);
            apex_json.write('message', 'Unable to get cumulative results');
            apex_json.close_object;           
    END cb_set_cumulative_coll;
    --
    FUNCTION  apex_error_handler (p_error in apex_error.t_error )
    return apex_error.t_error_result IS
        l_result          apex_error.t_error_result;
        l_reference_id    number;
        l_constraint_name varchar2(255);
    BEGIN
        l_result := apex_error.init_error_result (p_error => p_error );
        
        -- log error for example with an autonomous transaction and return
        -- l_reference_id as reference#
        l_reference_id := cims_apex_util_pkg.log_error(p_error => p_error);

        -- If it's an internal error raised by APEX, like an invalid statement or
        -- code which can't be executed, the error text might contain security sensitive
        -- information. To avoid this security problem we can rewrite the error to
        -- a generic error message and log the original error message for further
        -- investigation by the help desk.
        if p_error.is_internal_error then
            -- mask all errors that are not common runtime errors (Access Denied
            -- errors raised by application / page authorization and all errors
            -- regarding session and session state)
            if not p_error.is_common_runtime_error then                
                -- 
                -- Change the message to the generic error message which doesn't expose
                -- any sensitive information.
                l_result.message         := 'An unexpected internal application error has occurred. '||
                                            'Please contact your application administrator and provide '||
                                            'reference# '||to_char(l_reference_id, '999G999G999G990')||
                                            ' for further investigation.';
                l_result.additional_info := null;
            end if;
        else            
            -- we try to get a friendly error message from our constraint lookup configuration.
            -- If we don't find the constraint in our lookup table we fallback to
            -- the original ORA error message.
            if p_error.ora_sqlcode in (-1, -2091, -2290, -2291, -2292) then
                l_result.message         := 'An unexpected internal application error has occurred. '||
                                            'Please contact your application administrator and provide '||
                                            'reference# '||to_char(l_reference_id, '999G999G999G990')||
                                            ' for further investigation.';
                l_result.additional_info := null;
            elsif v('APP_PAGE_ID') = 6 AND (p_error.ora_sqlcode in (-1403) OR INSTR(p_error.message,'ORA-01403')>0) 
            then           
                   
                l_result.message := 'Cannot find patient with MRN "'||v('P6_MRN')||'"';
                l_result.additional_info := NULL;
            end if;


            -- If an ORA error has been raised, for example a raise_application_error(-20xxx, '...')
            -- in a table trigger or in a PL/SQL package called by a process and we
            -- haven't found the error in our lookup table, then we just want to see
            -- the actual error text and not the full error stack with all the ORA error numbers.
            if p_error.ora_sqlcode is not null and l_result.message = p_error.message then
                l_result.message := apex_error.get_first_ora_error_text (
                                        p_error => p_error );
            end if;

           
        end if;

        return l_result;
    
    END apex_error_handler;
    --
    /***************************************************************************************************************************
    ** PROCEDURE: CB_GET_REPORT
    ** This procedure is called in application AJAX process CB_GET_REPORT, to get the report PDF and render that on APEX page
    ** It also populate an audit record by calling API AUDIT_PACKAGE.Audit_report_result2. Parameter pSpfReport(BLOB type) is 
    ** NOT used in the API, NULL is passed in this procedure.
    ***************************************************************************************************************************/        
    PROCEDURE CB_GET_REPORT(p_req_key IN NUMBER,
                            p_rqt_key IN NUMBER)
    IS                        
        v_blob              BLOB;
        v_mime_type         VARCHAR2(500);
        v_temp              VARCHAR2(500);
        v_file_type         VARCHAR2(50);
        v_spf_key           NUMBER;
        v_spf_report_format VARCHAR2(50);
    BEGIN
        -- Get Blob File
        SELECT  SPF_REPORT AS blob_content,
                SPF_KEY,
                SPF_REPORT_FORMAT
        INTO    v_blob,
                v_spf_key,
                v_spf_report_format        
        FROM    spool_frame@apex_link s, 
                rept_req_test@apex_link r
        WHERE   r.req_key = p_req_key
        AND     r.rqt_key = p_rqt_key
        AND     s.SPF_IS_LAB = 'F'
        and     r.req_key = s.req_key
        and     r.rpt_key = s.rpt_key      
        and     s.spf_report is not null
        AND     rownum = 1
        ;
        --
        -- Try to determine mime type by reading the file
        SELECT  UPPER(utl_raw.cast_to_varchar2(dbms_lob.substr(v_blob,255))),
                dbms_lob.substr(v_blob,2,1) 
        INTO    v_temp, 
                v_file_type
        FROM    dual;
        
        IF v_file_type = '2550' OR INSTR(v_temp, 'PDF') > 0 THEN 
            v_mime_type := 'application/pdf';
        ELSIF INSTR(v_temp, 'RTF') > 0 THEN
            v_mime_type := 'application/rtf';
        ELSIF INSTR(v_temp, 'HTML') > 0 THEN
            v_mime_type := 'text/html';
        ELSIF v_file_type = 'D0CF' THEN
            v_mime_type := 'application/msword';   
        ELSIF v_file_type = '504B' THEN 
            v_mime_type := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        ELSE 
            v_mime_type :='application/octet-stream';        
        END IF;
        -- Display PDF
        htp.flush;
        htp.init;
        owa_util.mime_header(v_mime_type,false);
        htp.p('Content-Length: ' || dbms_lob.getlength(v_blob));
        owa_util.http_header_close; 
        -- htp.p( 'Content-Disposition: inline; filename="'||'report'||'.pdf"' );  
        --htp.p('Set-Cookie: fileDownload=true; path=/');            
        wpg_docload.download_file(v_blob);

        -- Audit 
        ILMS5.AUDIT_PACKAGE.AUDIT_REPORT_RESULT2@apex_link(
                    pSpfKey             => v_spf_key,
                    pReqKey             => p_req_key,
                    pRptKey             => p_rqt_key,
                    pSpfReportFormat    => v_spf_report_format,
                    pSpfReport          => NULL,
                    p_OSUSER            => V('APP_USER'), -- Windows Logon User = APP_USER
                    p_HOST              => owa_util.get_cgi_env ('REMOTE_ADDR'),
                    p_SessionUser       => V('G_OS_USER'),-- DBLOGON_USER,doctor/user ID passed from url 
                    p_Action            => 2
                    ); 
    EXCEPTION 
        WHEN others THEN    
            NULL;    
    END CB_GET_REPORT;    
END cims_apex_ctl_pkg;