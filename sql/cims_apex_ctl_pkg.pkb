CREATE OR REPLACE PACKAGE BODY cims_apex_ctl_pkg AS
/**************************************************************************
REM Change History Information
REM --------------------------
REM Version   Date         Author           Change Reference / Description
REM -------   -----------  ---------------  ------------------------------------
REM 1.0       30-SEP-2020  Frank Zhang      Initial Creation
REM ***************************************************************************/


    PROCEDURE print_log(
        p_log_message IN VARCHAR2
    )IS
    BEGIN
        --APEX_DEBUG.MESSAGE (p_message => 'GJ - '||p_log_message);
        APEX_DEBUG.INFO  (p_message => 'GJ - '||p_log_message);
    END print_log;   
    
    
    /***************************************************************************************************************************
    ** PROCEDURE: populate_cumulative_collection
    ** This procedure is used to populate apex_collections with cumulative results based on date range.
    ** The reason do to this is because the number of columns is unknown at design time. and APEX reports components need to know
    ** at design time. the limitation of this method is that apex_collections only allows 50 VARCHAR2 columns
    ***************************************************************************************************************************/
    PROCEDURE cb_populate_cumulative_collection(
        p_req_key    IN  NUMBER,
        p_rqt_key    IN  NUMBER,
        p_date_from  IN  VARCHAR2,
        p_date_to    IN  VARCHAR2
    )
    IS
        v_seq               NUMBER DEFAULT 0;
        v_sql_stmt1         VARCHAR2(3000);    
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
                    AND   TRUNC(req.req_relev_date) BETWEEN params.DATE_FROM AND params.DATE_TO
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
    END cb_populate_cumulative_collection;

END cims_apex_ctl_pkg;