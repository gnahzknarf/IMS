PACKAGE BODY       Audit_Package AS

-- FUNCTION MyFuncName ( inVal NUMBER ) RETURN NUMBER IS

/* Array of RTA Key records */

--    TmpVar NUMBER;

  TYPE TAUDITKeyTable

-- BEGIN

  IS

--    tmpVar := 0;

    TABLE OF REQUEST_TEST_AUDIT.RTA_KEY%Type NOT NULL

--    RETURN tmpVar;

    INDEX BY BINARY_INTEGER;

--    EXCEPTION



--      WHEN NO_DATA_FOUND THEN

  AUDITKeyTable TAUDITKeyTable;

--        NULL;

  emptyauditkeytable TAUDITKeyTable;

--      WHEN OTHERS THEN



--        -- Consider logging the error and then re-raise



--        RAISE;

--   FUNCTION MyFuncName ( inVal NUMBER ) RETURN NUMBER;

-- END MyFuncName;

  PROCEDURE AUDIT_REQUEST_TEST(ReqKey REQUEST_TEST.REQ_KEY%TYPE, RqtKey REQUEST_TEST.RQT_KEY%TYPE,



		OldAbnKey REQUEST_TEST.ABN_KEY%TYPE, NewAbnKey REQUEST_TEST.ABN_KEY%TYPE,

PROCEDURE AUDIT_REQUEST_TEST(ReqKey REQUEST_TEST.REQ_KEY%TYPE, RqtKey REQUEST_TEST.RQT_KEY%TYPE,

		NewResKey REQUEST_TEST.RES_KEY%TYPE, OldResKey REQUEST_TEST.RES_KEY%TYPE,

		OldAbnKey REQUEST_TEST.ABN_KEY%TYPE, NewAbnKey REQUEST_TEST.ABN_KEY%TYPE,

		TdKey REQUEST_TEST.TD_KEY%TYPE,

		NewResKey REQUEST_TEST.RES_KEY%TYPE, OldResKey REQUEST_TEST.RES_KEY%TYPE,

		NewRqtDesc REQUEST_TEST.RQT_DESC%TYPE, OldRqtDesc REQUEST_TEST.RQT_DESC%TYPE,

		TdKey REQUEST_TEST.TD_KEY%TYPE,

		ResOprKey  REQUEST_TEST.RESULTING_OPR_KEY%TYPE, EnterOprKey REQUEST_TEST.ENTERING_OPR_KEY%TYPE,

		NewRqtDesc REQUEST_TEST.RQT_DESC%TYPE, OldRqtDesc REQUEST_TEST.RQT_DESC%TYPE,

		VrfOprKey REQUEST_TEST.VERIFYING_OPR_KEY%TYPE, PthOprKey REQUEST_TEST.PATH_OPR_KEY%TYPE,

		ResOprKey  REQUEST_TEST.RESULTING_OPR_KEY%TYPE, EnterOprKey REQUEST_TEST.ENTERING_OPR_KEY%TYPE,

		ResDate REQUEST_TEST.RQT_RESULT_DATE%TYPE, ScnDate REQUEST_TEST.RQT_SCIENTIST_DATE%TYPE,

		VrfOprKey REQUEST_TEST.VERIFYING_OPR_KEY%TYPE, PthOprKey REQUEST_TEST.PATH_OPR_KEY%TYPE,

		ModDate REQUEST_TEST.RQT_MODIFIED_DATE%TYPE, PthDate REQUEST_TEST.RQT_PATH_DATE%TYPE);

		ResDate REQUEST_TEST.RQT_RESULT_DATE%TYPE, ScnDate REQUEST_TEST.RQT_SCIENTIST_DATE%TYPE,



		ModDate REQUEST_TEST.RQT_MODIFIED_DATE%TYPE, PthDate REQUEST_TEST.RQT_PATH_DATE%TYPE)

  PROCEDURE Update_Report_Audit_Result(pSpfKey SPOOL_FRAME.SPF_KEY%TYPE, pReqKey SPOOL_FRAME.REQ_KEY%TYPE, pRpaKey REPORT_AUDIT.RPA_KEY%TYPE, pLaydKey REPORT.LAYD_KEY%TYPE);

IS

  PROCEDURE AUDIT_REPORT_RESULT(pSpfKey SPOOL_FRAME.SPF_KEY%TYPE, pReqKey SPOOL_FRAME.REQ_KEY%TYPE, pRptKey SPOOL_FRAME.RPT_KEY%TYPE, pSpfReportFormat SPOOL_FRAME.SPF_REPORT_FORMAT%TYPE, pSpfReport SPOOL_FRAME.SPF_REPORT%TYPE);

   NO_STATUS_CODE EXCEPTION;



   ResStatus NUMBER;

PROCEDURE AUDIT_REPORT_RESULT2(pSpfKey SPOOL_FRAME.SPF_KEY%TYPE, pReqKey SPOOL_FRAME.REQ_KEY%TYPE, pRptKey SPOOL_FRAME.RPT_KEY%TYPE, pSpfReportFormat SPOOL_FRAME.SPF_REPORT_FORMAT%TYPE, pSpfReport SPOOL_FRAME.SPF_REPORT%TYPE,

   OprKey OPERATIVE.OPR_KEY%TYPE;

                                                        p_OSUSER VARCHAR2, p_HOST VARCHAR2, p_SessionUser VARCHAR2);

   NoteKey AUDIT_NOTE.AN_KEY%TYPE;



   ClientDate DATE;



   NewSeq INTEGER;



   vOSUser VARCHAR2 (32);

  PROCEDURE AUDIT_DOCUMENT_RESULT(ReqKey REQUEST_TEST_BLOB.REQ_KEY%TYPE, RqtKey REQUEST_TEST_BLOB.RQT_KEY%TYPE,

   vHost VARCHAR2 (32);

			  OldValue REQUEST_TEST_BLOB.RTB_VALUE%TYPE, NewValue REQUEST_TEST_BLOB.RTB_VALUE%TYPE,

   vUser varchar2 (32);

              OLDCOMPRESS REQUEST_TEST_BLOB.RTB_COMPRESSED%TYPE, NEWCOMPRESS REQUEST_TEST_BLOB.RTB_COMPRESSED%TYPE);

   CommentKey REQ_COM_REQ_TEST.REQ_KEY%TYPE;



   DocKey REQUEST_TEST_BLOB.RTB_KEY%TYPE;

  PROCEDURE AUDIT_CULTURE_RESULT(ReqKey CULTURE_ORGANISM.REQ_KEY%TYPE,

   JobNo INTEGER;

		  RqtKey CULTURE_ORGANISM.RQT_KEY%TYPE, OrgKey CULTURE_ORGANISM.ORG_KEY%TYPE,



				Prefix CULTURE_ORGANISM.CLOR_PREFIX%TYPE,

BEGIN

				Suffix CULTURE_ORGANISM.CLOR_SUFFIX%TYPE);

-- 1 Result changed AND Auto Pathologist Verified



-- 2 Result changed AND Auto Scientist Verified

  PROCEDURE AUDIT_SENSITIVITY_RESULT(ReqKey CULTURE_DRUG_ORGAN.REQ_KEY%TYPE,

-- 3 Result Changed AND Manual Pathologist Verified

-- 4 Result changed AND Manual Scientist Verified

		  RqtKey CULTURE_DRUG_ORGAN.RQT_KEY%TYPE, OrgKey CULTURE_DRUG_ORGAN.ORG_KEY%TYPE,

				DrugKey CULTURE_DRUG_ORGAN.DRUG_KEY%TYPE, MISKey CULTURE_DRUG_ORGAN.MIS_KEY%TYPE,

-- 5 Result Changed AND Unverified

				Note CULTURE_DRUG_ORGAN.CLDO_NOTE%TYPE,

-- 6 Result Changed

				MIC CULTURE_DRUG_ORGAN.CLDO_MIC%TYPE);

-- 7 Auto Pathologist Verified



-- 8 Auto Scientist Verified

  procedure AUDIT_COMMENTS(ReqKey REQ_COM_EXT.REQ_KEY%TYPE, ReqcKey REQ_COM_EXT.REQC_KEY%TYPE,

-- 9 Manual Pathologist Verified

                           NewComment REQ_COM_EXT.RCEX_LINES%TYPE, OldComment REQ_COM_EXT.RCEX_LINES%TYPE);

-- 10 Manual Scientist Verified



-- 11 Unverified

  procedure Update_Audit_Comment(ReqKey REQ_COM_EXT.REQ_KEY%TYPE, ReqcKey REQ_COM_EXT.REQC_KEY%TYPE, RTAKey REQUEST_TEST_AUDIT.RTA_KEY%TYPE, vMode INTEGER);

-- 12 Result Status changed



			dbms_output.put_line('Audit_Package.RequestTestAuditTrail: Enter');

  PROCEDURE Update_Audit_DOCUMENT(ReqKey REQUEST_TEST_BLOB.REQ_KEY%TYPE, RqtKey REQUEST_TEST_BLOB.RQT_KEY%TYPE, RTAKey REQUEST_TEST_AUDIT.RTA_KEY%TYPE, vMode INTEGER);

			-- Work out the action status



   IF (NewRqtDesc <> OldRqtDesc) THEN

/******************************************************************************

	   BEGIN

   NAME:       AUDIT_PACKAGE

		   IF (NewResKEY = Ilms_Site_Bob.ILMSSiteRow.PATH_RES_KEY) THEN

   PURPOSE:    To create ILMS result trail.

		     BEGIN



		       IF (PthOprKey IS NULL) THEN

   REVISIONS:

			       ResStatus := 1;

   Ver        Date        Author           Description

           ELSE

   ---------  ----------  ---------------  ------------------------------------

             ResStatus := 3;

   1.0        14/07/2004             1. Created this package.

           END IF;



         END;

   PARAMETERS:

       ELSIF (NewResKEY = Ilms_Site_Bob.ILMSSiteRow.SCIENTIST_RES_KEY) THEN

   INPUT:

         BEGIN

   OUTPUT:

					 IF (VrfOprKey IS NULL) THEN

   RETURNED VALUE:

					   ResStatus := 2;

   CALLED BY:

					 ELSE

   CALLS:

					   ResStatus := 4;

   EXAMPLE USE:     NUMBER := AUDIT_PACKAGE.MyFuncName(Number);

					 END IF;

                    AUDIT_PACKAGE.MyProcName(Number, Varchar2);

				 END;

   ASSUMPTIONS:

			 ELSIF (NewResKey =Ilms_Site_Bob.ILMSSiteRow.RESULTED_RES_KEY) AND

   LIMITATIONS:

					  ( (oldResKey = Ilms_Site_Bob.ILMSSiteRow.SCIENTIST_RES_KEY) OR

   ALGORITHM:

						  (oldResKey = Ilms_Site_Bob.ILMSSiteRow.PATH_RES_KEY) ) THEN

   NOTES:

  		   ResStatus := 5;



			 ELSE

   Here is the complete list of available Auto Replace Keywords:

			   ResStatus := 6;

      Object Name:     AUDIT_PACKAGE or AUDIT_PACKAGE

			 END IF;

      Sysdate:         14/07/2004

		 END;

      Date/Time:       14/07/2004 10:09:29 AM

	 ELSE

      Date:            14/07/2004

     BEGIN

      Time:            10:09:29 AM

		   IF (NewResKEY = Ilms_Site_Bob.ILMSSiteRow.PATH_RES_KEY) THEN

      Username:         (set in TOAD Options, Procedure Editor)

			   BEGIN

      Trigger Options: %TriggerOpts%

				   IF (PthOprKey IS NULL) THEN

******************************************************************************/

					   ResStatus := 7;

END Audit_Package;
					 ELSE

					   ResStatus := 9;

					 END IF;

				 END;

			 ELSIF (NewResKEY = Ilms_Site_Bob.ILMSSiteRow.SCIENTIST_RES_KEY) THEN

			   BEGIN

				   IF (VrfOprKey IS NULL) THEN

				 	   ResStatus := 8;

					 ELSE

					   ResStatus := 10;

					 END IF;

				 END;

			 ELSIF (NewResKey =Ilms_Site_Bob.ILMSSiteRow.RESULTED_RES_KEY) AND

			 	   ( (oldResKey = Ilms_Site_Bob.ILMSSiteRow.SCIENTIST_RES_KEY) OR

					   (oldResKey = Ilms_Site_Bob.ILMSSiteRow.PATH_RES_KEY) ) THEN

  			 ResStatus := 11;

			 ELSE

			   ResStatus := 12;

			 END IF;

		 END;

	 END IF;

   -- Define responsible  operative and date time.

	 CASE ResStatus

			WHEN 7 THEN

			  OprKey := 1; -- ILMS5

				ClientDate := PthDate;

			WHEN 8 THEN

			  OprKey := 1;

				ClientDate := ScnDate;

			WHEN 9 THEN

			  OprKey := PthOprKey;

				ClientDate := PthDate;

			WHEN 10 THEN

			  OprKey := VrfOprKey;

				ClientDate := ScnDate;

			WHEN 11 THEN

			  OprKey := EnterOprKey;

				ClientDate := ModDate;

			ELSE

			  IF	ResStatus IN (1,2,3,4,5,6,12) THEN

          OprKey := ResOprKey;

		    	ClientDate := ModDate;

			  ELSE

     			dbms_output.put_line('Audit_Package.RequestTestAuditTrail: Unhandled status code.');

					RAISE NO_STATUS_CODE;

				END IF;

	 END CASE;



	 NewSeq := Sp_Getnextseq('REQUEST_TEST_AUDIT');

			

   vOSUser := TRIM(sys_context('userenv','os_user',32));

	

   vHost := TRIM(sys_context('userenv','host',32));



   vUser := TRIM(sys_context('userenv','SESSION_USER',32));



	-- Insert the audit trail

	 INSERT INTO REQUEST_TEST_AUDIT(RTA_KEY,REQ_KEY,RQT_KEY,OLD_RES,OLD_ABN,OLD_RESULT,OPR_KEY,

			  DBLOGON_USER,OS_USER,HOST,CLIENT_DATE,SYS_DATE,AN_KEY,TD_KEY, NEW_RES, NEW_ABN, NEW_RESULT)

			VALUES (NewSeq,ReqKey,RqtKey,OldResKey,OldAbnKey,OldRqtDesc,OprKey,vUSER,vOSUser,vHost,ClientDate,

			SYSDATE,ResStatus,TdKey, NewResKey, NewAbnKey, NewRqtDesc);



      -- e are unverifing.

--      if ((OldResKey = 5) and (NewResKey = 3)) then



   -- Has a document

   if NewRqtDesc = '*See Document*' then



--   select nvl(RTB_KEY, -1) INTO DocKey from REQUEST_TEST_BLOB where req_key = Reqkey and rqt_key = rqtkey;

--   if DocKey > 0 then



     UPDATE REQUEST_TEST_AUDIT SET

        OLD_COMPRESSED = (Select RTB_COMPRESSED from REQUEST_TEST_BLOB where req_key = reqkey and rqt_key = rqtkey),

        NEW_COMPRESSED = (Select RTB_COMPRESSED from REQUEST_TEST_BLOB where req_key = reqkey and rqt_key = rqtkey),

        OLD_RESULT_DOC = (Select RTB_VALUE from REQUEST_TEST_BLOB where req_key = reqkey and rqt_key = rqtkey)

--        Flags = Flags || '| Request test Audit '

     WHERE RTA_KEY	= NewSeq;



     dbms_job.SUBMIT(JobNo,'ILMS5.Audit_Package.Update_Audit_DOCUMENT('||ReqKey||','||Rqtkey||','||NewSeq||',''2'');');  -- new doc



--     dbms_job.SUBMIT(JobNo,'ILMS5.Audit_Package.Update_Audit_DOCUMENT('||ReqKey||','||Rqtkey||','||NewSeq||',''3'');');  -- old doc



--          UPDATE REQUEST_TEST_AUDIT SET

--            NEW_COMPRESSED = (Select RTB_COMPRESSED from REQUEST_TEST_BLOB where req_key = reqkey and rqt_key = rqtkey),

--            NEW_RESULT_DOC = (Select RTB_VALUE from REQUEST_TEST_BLOB where req_key = reqkey and rqt_key = rqtkey)

--          WHERE RTA_KEY	= NewSeq;

   end if;



   -- Has a comment

     select nvl(REQC_KEY, -1) INTO CommentKey from REQ_COM_REQ_TEST where req_key = Reqkey and rqt_key = rqtkey;

     if CommentKey > 0 then



       dbms_job.SUBMIT(JobNo,'ILMS5.Audit_Package.Update_Audit_Comment('||ReqKey||','||CommentKey||','||NewSeq||',''3'');'); -- Old Comment



       dbms_job.SUBMIT(JobNo,'ILMS5.Audit_Package.Update_Audit_Comment('||ReqKey||','||CommentKey||','||NewSeq||',''2'');'); -- New Comment





--          UPDATE REQUEST_TEST_AUDIT SET

--           NEW_RESULT_COMMENT = (Select RCEX_LINES from req_com_ext where req_key = reqkey and reqc_key = CommentKey)

--          WHERE RTA_KEY	= NewSeq;



--          UPDATE REQUEST_TEST_AUDIT SET

--           OLD_RESULT_COMMENT = (Select RCEX_LINES from req_com_ext where req_key = reqkey and reqc_key = CommentKey)

--          WHERE RTA_KEY	= NewSeq;

     end if;



 	dbms_output.put_line('Audit_Package.RequestTestAuditTrail: Exit');

 EXCEPTION

	  WHEN OTHERS THEN

				dbms_output.put_line('Audit_Package.RequestTestAuditTrail: '||SQLERRM);

END;





PROCEDURE AUDIT_COMMENTS(ReqKey REQ_COM_EXT.REQ_KEY%TYPE, ReqcKey REQ_COM_EXT.REQC_KEY%TYPE, NewComment REQ_COM_EXT.RCEX_LINES%TYPE, OldComment REQ_COM_EXT.RCEX_LINES%TYPE)

IS

  RTAKEY Integer;

  CTYPE Integer;

  RTACKey Integer;

  JobNo INTEGER;

BEGIN



  select

     NVL(max(rta.RTA_KEY), 0) INTO RTAKEY

  from

     Request_test_audit rta, req_com_req_test rcrt

  where

     RCRT.REQ_KEY = ReqKey

     and  RCRT.REQC_KEY  = ReqcKey

     and  RTA.REQ_KEY = RCRT.REQ_KEY

     and  RTA.RQT_KEY = RCRT.RQT_KEY;



  select

     RC.REQC_TYPE into CTYPE

  from

     Request_comment rc

  where RC.REQ_KEY = ReqKey

   and  RC.REQC_KEY = Reqckey;





-- Note that we only want to audit comment type 3 (results), not 4 or 5.



  if (RTAKEY > 0) and (CTYPE = 3) then



    UPDATE REQUEST_TEST_AUDIT SET

        OLD_RESULT_COMMENT = OldComment

    WHERE RTA_KEY = RTAKEY;



    dbms_job.SUBMIT(JobNo,'ILMS5.Audit_Package.Update_Audit_Comment('||ReqKey||','||Reqckey||','||RTAKEY||',''1'');');



  end if;



END;





procedure Update_Audit_Comment(ReqKey REQ_COM_EXT.REQ_KEY%TYPE, ReqcKey REQ_COM_EXT.REQC_KEY%TYPE, RTAKey REQUEST_TEST_AUDIT.RTA_KEY%TYPE, vMode INTEGER)

IS

BEGIN

  if vMode = 1 then

    UPDATE REQUEST_TEST_AUDIT SET

        NEW_RESULT_COMMENT = (Select RCEX_LINES from req_com_ext where req_key = reqkey and reqc_key = reqckey)

    WHERE RTA_KEY	= RTAKEY;

    commit;

  end if;

  if vMode = 2 then

    UPDATE REQUEST_TEST_AUDIT SET

        NEW_RESULT_COMMENT = (Select RCEX_LINES from req_com_ext where req_key = reqkey and reqc_key = reqckey)

    WHERE RTA_KEY	= RTAKEY AND NEW_RESULT_COMMENT IS NULL;

--    commit;

  end if;

  if vMode = 3 then

    UPDATE REQUEST_TEST_AUDIT SET

        OLD_RESULT_COMMENT = (Select RCEX_LINES from req_com_ext where req_key = reqkey and reqc_key = reqckey)

    WHERE RTA_KEY	= RTAKEY AND OLD_RESULT_COMMENT IS NULL;

--    commit;

  end if;

END;





PROCEDURE AUDIT_REPORT_RESULT(pSpfKey SPOOL_FRAME.SPF_KEY%TYPE, pReqKey SPOOL_FRAME.REQ_KEY%TYPE, pRptKey SPOOL_FRAME.RPT_KEY%TYPE, pSpfReportFormat SPOOL_FRAME.SPF_REPORT_FORMAT%TYPE, pSpfReport SPOOL_FRAME.SPF_REPORT%TYPE)

IS

  lOSUser VARCHAR2 (32);

  lHost VARCHAR2 (32);

  lUser varchar2 (32);

BEGIN

   

  lOSUser := TRIM(sys_context('userenv','os_user',32));			

  lHost   := TRIM(sys_context('userenv','host',32));

  lUser   := TRIM(sys_context('userenv','SESSION_USER',32));



  AUDIT_REPORT_RESULT2(pSpfKey, pReqKey, pRptKey, pSpfReportFormat, pSpfReport, lUser, lOSUser, lHost);



END;



PROCEDURE AUDIT_REPORT_RESULT2(pSpfKey SPOOL_FRAME.SPF_KEY%TYPE, pReqKey SPOOL_FRAME.REQ_KEY%TYPE, pRptKey SPOOL_FRAME.RPT_KEY%TYPE, pSpfReportFormat SPOOL_FRAME.SPF_REPORT_FORMAT%TYPE, pSpfReport SPOOL_FRAME.SPF_REPORT%TYPE,

                                                        p_OSUSER VARCHAR2, p_HOST VARCHAR2, p_SessionUser VARCHAR2)

IS

  lRpaKey Integer;

  lLaydKey Integer;

  lOSUser VARCHAR2 (32);

  lHost VARCHAR2 (32);

  lUser varchar2 (32);

  lJobNo INTEGER;

  lRptVersion INTEGER;

BEGIN



  select LAYD_KEY into lLaydKey

    from Report r

    where R.REQ_KEY = pReqKey

      and R.RPT_KEY = pRptKey;



  select NVL(max(RPA_KEY), 0) INTO lRpaKey

    from Report_audit ra

    where RA.REQ_KEY = pReqKey

     and  RA.LAYD_KEY = lLaydKey;



  select NVL(max(REPORT_VERSION), 0) INTO lRptVersion

    from Report_audit ra

    where RA.REQ_KEY = pReqKey

     and  RA.LAYD_KEY = lLaydKey;

     

  lRpaKey := lRpaKey + 1;

  lRptVersion := lRptVersion +1;

  

--  lOSUser := TRIM(sys_context('userenv','os_user',32));            

--  lHost   := TRIM(sys_context('userenv','host',32));

--  lUser   := TRIM(sys_context('userenv','SESSION_USER',32));



  lOSUser := p_OSUSER;            

  lHost   := p_HOST;

  lUser   := p_SessionUser;





  INSERT INTO

    ILMS5.REPORT_AUDIT (REQ_KEY, RPA_KEY, LAYD_KEY, DBLOGON_USER, OS_USER, HOST, SYS_DATE, REPORT_FORMAT, SPF_VALUE, REPORT_VERSION, ACTION)

  VALUES

    ( pReqKey, lRpaKey, lLaydKey, lUser, lOSUser, lHost, SYSDATE, pSpfReportFormat, NULL, lRptVersion, 1);



  dbms_job.SUBMIT(lJobNo,'ILMS5.Audit_Package.Update_Report_Audit_Result('||pSpfKey||','||pReqKey||','||lRpaKey||','||lLaydKey||');');



END;

                                                        





PROCEDURE Update_Report_Audit_Result(pSpfKey SPOOL_FRAME.SPF_KEY%TYPE, pReqKey SPOOL_FRAME.REQ_KEY%TYPE, pRpaKey REPORT_AUDIT.RPA_KEY%TYPE, pLaydKey REPORT.LAYD_KEY%TYPE)

IS

BEGIN



  UPDATE REPORT_AUDIT SET

        SPF_VALUE = (Select SPF_REPORT from spool_frame where spf_key = pSpfKey)

  WHERE REQ_KEY	= pReqKey and

        RPA_KEY = pRpaKey and

        LAYD_KEY = pLaydKey;

  commit;

END;



PROCEDURE   AUDIT_DOCUMENT_RESULT(ReqKey REQUEST_TEST_BLOB.REQ_KEY%TYPE, RqtKey REQUEST_TEST_BLOB.RQT_KEY%TYPE,

			  OldValue REQUEST_TEST_BLOB.RTB_VALUE%TYPE, NewValue REQUEST_TEST_BLOB.RTB_VALUE%TYPE,

              OLDCOMPRESS REQUEST_TEST_BLOB.RTB_COMPRESSED%TYPE, NEWCOMPRESS REQUEST_TEST_BLOB.RTB_COMPRESSED%TYPE)

IS

  RTAKEY Integer;

  JobNo INTEGER;



BEGIN

  -- This trigger is fired twice for each update of the request_test_Blob record, the first fire includes the correct

  -- old value of RTB_VALUE, the second fire has the new value as the old value.

  -- So we need to add the rta key to a "inprocess" list on the first fire, and remove it at the end of the 2nd fire.





  select NVL(max(RTA_KEY), 0) INTO RTAKEY

    from Request_test_audit rta

    where RTA.REQ_KEY = ReqKey

     and  RTA.RQT_KEY = RqtKey;



  if RTAKEY > 0 then



    if AUDITKeyTable.COUNT = 0 then

      AUDITKeyTable(0) := RTAKEY;



    update REQUEST_TEST_AUDIT R

    set

      R.OLD_RESULT_DOC = OldValue,

      R.OLD_COMPRESSED = OLDCOMPRESS,

      R.NEW_COMPRESSED = NEWCOMPRESS

--      Flags = Flags || '| Audit doc res '

    where R.RTA_KEY = RTAKEY;



    else



--    update REQUEST_TEST_AUDIT R

--    set

--      R.NEW_RESULT_DOC = OldValue,

--      R.NEW_COMPRESSED = OLDCOMPRESS

--    where RTA_KEY = RTAKEY;



      AUDITKeyTable := emptyauditkeytable;

    end if;

  end if;



  dbms_job.SUBMIT(JobNo,'ILMS5.Audit_Package.Update_Audit_DOCUMENT('||ReqKey||','||Rqtkey||','||Rtakey||',''1'');');





--  if RTAKEY > 0 then

--   INSERT INTO REQUEST_TEST_BLOB_AUDIT(RTA_KEY,REQ_KEY,RQT_KEY,OLD_RESULT,DBLOGON_USER,OS_USER,HOST,CLIENT_DATE,SYS_DATE,NEW_RESULT)

--      VALUES (RTAKEY, ReqKey, RqtKey, OldValue, vUSER, vOSUser,vHost, sysdate, sysdate, NewValue);

--  end if;



END;



PROCEDURE Update_Audit_DOCUMENT(ReqKey REQUEST_TEST_BLOB.REQ_KEY%TYPE, RqtKey REQUEST_TEST_BLOB.RQT_KEY%TYPE, RTAKey REQUEST_TEST_AUDIT.RTA_KEY%TYPE, vMode INTEGER)

IS

begin

  if vMode = 1 then

    UPDATE REQUEST_TEST_AUDIT SET

       NEW_RESULT_DOC = (Select RTB_VALUE from REQUEST_TEST_BLOB where req_key = reqkey and rqt_key = rqtkey)

    WHERE RTA_KEY	= RTAKEY;

    commit;

  end if;

  if vMode = 2 then

    UPDATE REQUEST_TEST_AUDIT SET

       NEW_RESULT_DOC = (Select RTB_VALUE from REQUEST_TEST_BLOB where req_key = reqkey and rqt_key = rqtkey)

    WHERE RTA_KEY	= RTAKEY AND NEW_RESULT_DOC IS NULL;

 --   commit;

  end if;

  if vMode = 3 then

    UPDATE REQUEST_TEST_AUDIT SET

       OLD_RESULT_DOC = (Select RTB_VALUE from REQUEST_TEST_BLOB where req_key = reqkey and rqt_key = rqtkey)

    WHERE RTA_KEY	= RTAKEY AND OLD_RESULT_DOC IS NULL;

 --   commit;

  end if;

end;



PROCEDURE AUDIT_CULTURE_RESULT(ReqKey CULTURE_ORGANISM.REQ_KEY%TYPE,

		  RqtKey CULTURE_ORGANISM.RQT_KEY%TYPE, OrgKey CULTURE_ORGANISM.ORG_KEY%TYPE,

				Prefix CULTURE_ORGANISM.CLOR_PREFIX%TYPE,

				Suffix CULTURE_ORGANISM.CLOR_SUFFIX%TYPE) IS

COAKey NUMBER;



BEGIN

  COAKey := Sp_Getnextseq('AUDIT_CULTURE_RESULT');

		INSERT INTO  CULTURE_ORGANISM_AUDIT VALUES

		(COAKey, ReqKey, RqtKey, OrgKey, Prefix, Suffix);

END;





PROCEDURE AUDIT_SENSITIVITY_RESULT(ReqKey CULTURE_DRUG_ORGAN.REQ_KEY%TYPE,

		  RqtKey CULTURE_DRUG_ORGAN.RQT_KEY%TYPE, OrgKey CULTURE_DRUG_ORGAN.ORG_KEY%TYPE,

				DrugKey CULTURE_DRUG_ORGAN.DRUG_KEY%TYPE, MISKey CULTURE_DRUG_ORGAN.MIS_KEY%TYPE,

				Note CULTURE_DRUG_ORGAN.CLDO_NOTE%TYPE,

				MIC CULTURE_DRUG_ORGAN.CLDO_MIC%TYPE

) IS



CDOAKey NUMBER;

BEGIN

  CDOAKey := Sp_Getnextseq('AUDIT_CULTURE_RESULT');

		INSERT INTO  CULTURE_DRUG_ORGAN_AUDIT VALUES

		(CDOAKey, ReqKey, RqtKey, DrugKey, OrgKey, MISKey, Note, MIC);

END;



END Audit_Package;
