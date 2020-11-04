/**
 *   (C) Copyright - Integrated Medical Technology Pty Ltd. 1993 - 2020. All rights reserved.
 *
 * @desc Top-level namespace. DO NOT CHANGE
 * @namespace cims_apex
**/
var cims_apex = cims_apex || {}; 

/**
 * @desc Namespace for util
 * @namespace cims_apex.util
**/
cims_apex.util = cims_apex.util || {};


cims_apex.util = function(debug,$){
    var module = {}; // used for expose public properties/functions
    
    module.currentAppId = apex.item('pFlowId').getValue();
    module.currentPageId = apex.item('pFlowStepId').getValue();
    module.currentSession = apex.item('pInstance').getValue();    

    function privateLog(){
        //Array.prototype.unshift.call(arguments);
        debug.info.apply(debug,arguments);
    }

    /**
     * @method log
     * @static
     * @desc   print log message in browser console when apex page is in debug mode
     * @param  {string} name Name of the function          
     * @param  {string} msg Message to Log
     * @param  {*} arguments arguments passed to the function
     */     
    module.log = function(name,msg,arguments){    
        privateLog("** CIMS log | " + name, msg, arguments); 
    };

	/**
     * @method showError
     * @static
     * @desc   Show page or inline Error
     * @param {string} errMsg Error Message to Display
	 * @param {string} pItem Item associcated with inline error
     */       
	module.showError = function(errMsg,pItem){
		if (arguments.length == 0){
			console.log("pMsg not passed");
		}else if (arguments.length == 1){	
			privateLog("item not passed");
			apex.message.clearErrors();    
			apex.message.showErrors([
				{type:       "error",
				location:   ["page"],
				message:    errMsg,
				unsafe:     true
				}
			]);         		
		}else{
			console.log("item passed");
			apex.item(pItem).setFocus();
			apex.message.showErrors(
			[
				{type:"error",
				 location:[ "page", "inline" ],
				 pageItem :pItem,
				 message:errMsg,
				 unsafe:false
				}
			]
        );  			
		}
	};
	 
    /**
     * @method showPageError
     * @static
     * @desc   Show page level Error
     * @param {string} errMsg Error Message to Display
     */       
    module.showPageError = function(errMsg){
        showError(errMsg);
    };
    /**
     * @method showAjaxError
     * @static
     * @desc   Grab Error info from AJAX call and dsiplay at page level
     * @param jqXHR
     * @param textStatus
     * @param errorThrown
     */               
    module.showAjaxError = function(jqXHR, textStatus, errorThrown){
        privateLog("Begin showAjaxError");
        privateLog("jqXHR",jqXHR);
        privateLog("textStatus",textStatus);
        privateLog("errorThrown",errorThrown);
        errorList = [];
    
        
        if(jqXHR.responseJSON && jqXHR.responseJSON.error){
            pushToErrorList(jqXHR.responseJSON.error);        
        }else if (jqXHR.responseText){
            pushToErrorList(jqXHR.responseText);        
        }else if (jqXHR){ // line level error        
            msgList = [];
            for (i = 0; i < jqXHR.length; i++) {            
                if(jqXHR[i].message ){                
                    msgList.push(jqXHR[i].message);
                }
            }
            //var uniqueList = Array.from(new Set(msgList)); // IE does NOT support Array.from
            var uniqueList = msgList.filter(function(currentValue,index,self){
                return self.indexOf(currentValue) === index;
            });
            
            console.log("uniqueList",uniqueList);
            for (i = 0; i < uniqueList.length; i++) {            
                pushToErrorList(uniqueList[i],["page","inline"]); 
            }
        }
            
        apex.message.clearErrors();
        apex.message.showErrors(errorList);
    };       

    return module;
    
}(apex.debug, apex.jQuery);

