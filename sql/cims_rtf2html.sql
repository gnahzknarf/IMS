create or replace function cims_rtf2html(p_req_key IN NUMBER,
                                         p_rqt_key IN NUMBER)
RETURN VARCHAR2 IS

    l_policy_name VARCHAR2(30) := 'rtf2html_policy';
    policy_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(policy_exists, -20000);
    --
    CURSOR cur_rtf IS              
        SELECT  RCEX_LINES as BLOB_CONTENT     
        FROM    ILMS5.REQ_COM_REQ_TEST reqc,
                ILMS5.REQ_COM_EXT rcex
        WHERE   reqc.REQC_KEY = rcex.REQC_KEY
        AND     reqc.rqt_key = p_rqt_key 
        AND     reqc.req_key = p_req_key
        AND     rownum = 1;
    l_rtf   BLOB;    
    l_html  CLOB;
BEGIN
    BEGIN
        ctx_ddl.create_policy(policy_name => l_policy_name, 
                              FILTER      => 'CTXSYS.AUTO_FILTER');  
    EXCEPTION
        WHEN policy_exists THEN
            dbms_output.put_line('policy exists');
    END;
    --
    OPEN  cur_rtf;
    FETCH cur_rtf INTO l_rtf;
    CLOSE cur_rtf;
    --
    ctx_doc.policy_filter(policy_name => l_policy_name,
                          document    => l_rtf,
                          restab      => l_html,
                          plaintext   => FALSE);
    --
    INSERT INTO RTF2HTML_TEMP
                            (
                            req_key         ,
                            rqt_key         ,
                            html_content    
                            )
    VALUES (p_req_key,p_rqt_key,l_html);
    --
    RETURN 'SUCCESS';
exception
  when others then
    return 'FAIL';  
END;