/**
 * @desc Top-level namespace. DO NOT CHANGE
 * @namespace cims_apex
**/
var cims_apex = cims_apex || {}; 

/**
 * @desc Namespace for cims.
 * @namespace cims_apex.cims
**/
cims_apex.cims = cims_apex.cims || {};

cims_apex.cims = (function process(cimsUtil,$){
    // Methods defined in utils package
    //var currentAppId = cimsUtil.currentAppId;
    var currentPageId = cimsUtil.currentPageId;
    var currentSession = cimsUtil.currentSession;
    var log = cimsUtil.log;
    var showError = cimsUtil.showError;
    var showAjaxError = cimsUtil.showAjaxError;

    var module = {}; // Used to expose public functi
    var functionName = 'cims_apex.cims';
    var msgObj = {
        selectOneRecord        : "Please select at least 1 record.",        
    };


    /**********************************************************************************************************************************
     * @function irRowhighLight
     * @example 
     * @desc   private function called in whenClickIRRow highlight current row
     **********************************************************************************************************************************/  
    function irRowhighLight( pThis ){
        $('td').removeClass('currentrow');
        //$(pThis).parent().parent().children().addClass('currentrow') ;  
        $(pThis).closest('tr').children().addClass('currentrow') ;  
       
    };

    /**********************************************************************************************************************************
     * @function search
     * @example cims_apex.cims.search();
     * @desc   this function is called when search button is clicked
     **********************************************************************************************************************************/  
    module.search = function(){
        functionName = 'cims_apex.cims.search';        
        log(functionName,"Begin. pageNo: " + currentPageId, arguments);        
        if (currentPageId == 2){//cumulative results page
            var reqKey = apex.item("P2_REQ_KEY").getValue();
            var rqtKey = apex.item("P2_RQT_KEY").getValue();
            var dateFrom = apex.item("P2_DATE_FROM").getValue();
            var dateTo = apex.item("P2_DATE_TO").getValue();
            log("reqKey",reqKey);
            log("rqtKey",rqtKey);
            log("dateFrom",dateFrom);
            log("dateTo",dateTo);


            searchPromise = function(){
                return apex.server.process(
                            "CB_POPULATE_CUMULATIVE_COLLECTION",
                            {   x01: reqKey,
                                x02: rqtKey,
                                x03: dateFrom,
                                x04: dateTo
                            }
                        );
            };               

            loadingIndicator= apex.widget.waitPopup();
            searchPromise()
                .then(function(data){
                    console.log("promise resolved", data);
                    if (!data.success){
                        log("searchPromise Promise resolved. error: ", data.message);
                        showError(data.message);
                    }else{
                        var colName;
                        //Reset existing header label items
                        for(idx = 4; idx<=49; idx++){
                            var s = "000" + idx;
                            var seq = s.substr(s.length-3);                            
                            colName= "P2_LABEL_C" + seq;                            
                            apex.item(colName).setValue("");
                        }
  


                        //Set column header label items
                        var colHdrArray = data.column_headers;
                        var colHdr;
                        
                        if (colHdrArray.length > 0 ){
                            for (idx = 0; idx < colHdrArray.length; idx ++){
                                colName= "P2_LABEL_" + colHdrArray[idx].C002;
                                colHdr = colHdrArray[idx].C003;
                                
                                log("colName",colName);
                                log("colHdr",colHdr);
                                apex.item(colName).setValue(colHdr);
                            }
                        }
                        // force value into session state, as report column has server side conditions which needs session state values
                        return apex.server.process('DUMMY',
                                            {pageItems: '#P2_LABEL_C004, #P2_LABEL_C005, #P2_LABEL_C006, #P2_LABEL_C007, #P2_LABEL_C008, #P2_LABEL_C009, #P2_LABEL_C010, ' +
                                                        '#P2_LABEL_C011, #P2_LABEL_C012, #P2_LABEL_C013, #P2_LABEL_C014, #P2_LABEL_C015, #P2_LABEL_C016, #P2_LABEL_C017, #P2_LABEL_C018, #P2_LABEL_C019, #P2_LABEL_C020,' +
                                                        '#P2_LABEL_C021, #P2_LABEL_C022, #P2_LABEL_C023, #P2_LABEL_C024, #P2_LABEL_C025, #P2_LABEL_C026, #P2_LABEL_C027, #P2_LABEL_C028, #P2_LABEL_C029, #P2_LABEL_C030,' +
                                                        '#P2_LABEL_C031, #P2_LABEL_C032, #P2_LABEL_C033, #P2_LABEL_C034, #P2_LABEL_C035, #P2_LABEL_C036, #P2_LABEL_C037, #P2_LABEL_C038, #P2_LABEL_C039, #P2_LABEL_C040,' +
                                                        '#P2_LABEL_C041, #P2_LABEL_C042, #P2_LABEL_C043, #P2_LABEL_C044, #P2_LABEL_C045, #P2_LABEL_C046, #P2_LABEL_C047, #P2_LABEL_C048, #P2_LABEL_C049'
                                            },
                                            {dataType: "text"}
                        );
                        
                    }                      
                })                
                .catch(showAjaxError)
                .then(function(){//cleanup    
                    loadingIndicator.remove();                    
                    // refresh region
                    $("#cumulative_dsp_rn").show();
                    apex.region("cumulative_dsp_rn").refresh();
                });            
        }   
        log(functionName, "End");
    },
    /**********************************************************************************************************************************
     * @function afterRefresh
     * @example cims_apex.cims.afterRefresh(this);
     * @desc   this function is called after Interactive Report refreshes
     **********************************************************************************************************************************/                         
    module.afterRefresh = function(){
        functionName = 'cims_apex.cims.afterRefresh';        
        log(functionName,"Begin. pageNo: " + currentPageId, arguments);      
        var id = arguments[0].triggeringElement.id;
        log("triggeringElement.id",id)
        if (currentPageId == 2 && id == "cumulative_dsp_rn"){
            //highlight cells
            $("td:contains('+')").css('color','red');
            $("td:contains('-')").css('color','red');
            $("td[headers='RANGE']").css('color','');
            
            // Remember the row users clicked before changing date range, trigger click event after IR refresh. 
            // P2_LINE_TD_NAME is populated when user manually click an IR row
            var selectedTd = apex.item("P2_LINE_TD_NAME").getValue();
            if (selectedTd != ""){                        
                var tdSelector = "#cumulative_dsp_rn td:nth-child(1):contains("+ selectedTd +")";
                $(tdSelector).click();
            }else{
                apex.region("cumulative_chart_rn").refresh();
            }
        }else if(currentPageId == 6 && id == "results_rn"){
            // rebuid IR control break description
            $("th.a-IRR-header.a-IRR-header--group").each( function(i,val){
                var cb= $(val).text();
                log("Existing control break desc",cb);
                var cbArray= cb.split(",");
                var obj = {};
                for (var i=0; i<cbArray.length; i++){
                    var nvp = cbArray[i].split(":");
                    if (nvp[0].trim() =="Date"){
                        obj[nvp[0].trim()] = nvp[1].trim() + ":" +nvp[2].trim();
                    }else{
                        obj[nvp[0].trim()] = nvp[1].trim();	
                    }
                }
                var newDesc = obj.Discipline + " (" + obj.Department + ") " + obj.Date;
                $(val).html(newDesc);
            });
        }        

        log(functionName, "End");
    },    
    /**********************************************************************************************************************************
     * @function whenClickIRRow
     * @example cims_apex.cims.whenClickIRRow(this);
     * @desc   this function is called when clicking Interactive Report Row
     **********************************************************************************************************************************/                         
    module.whenClickIRRow = function(){
        functionName = 'cims_apex.cims.whenClickIRRow';        
        log(functionName,"Begin. pageNo: " + currentPageId, arguments);        
        var te = arguments[0].triggeringElement;
        if (currentPageId == 2){
            //set color, function defined on page propery
            irRowhighLight( te );

            var id = $(te).closest('tr').find('td[headers="TD_NAME"]').text(); 
            var range =  $(te).closest('tr').find('td[headers="RANGE"]').text(); 
            var units =  $(te).closest('tr').find('td[headers="UNITS"]').text(); 
            log("TD_NAME",id);
            log("unit",units);
            
            if (units != ""){// only refresh if there is units, others are text results
                console.log("unit is not null");
                apex.item("P2_LINE_TD_NAME").setValue(id);
                apex.item("P2_LINE_UNIT").setValue(units);
                
                $("#cumulative_chart_rn").show();
                var title = "Cumulative Results Chart : " + id +" " + range + " " + units ; 
                $("#cumulative_chart_rn_heading").text(title);

                //This is a dummy process that saves client value to session state so they can be used by y axis
                apex.server.process('DUMMY',{pageItems: '#P2_LINE_UNIT,#P2_LINE_TD_NAME'},{dataType: "text"});

                apex.region("cumulative_chart_rn").refresh();
            }else{
                $("#cumulative_chart_rn").hide();
            }
        }if (currentPageId == 6){
            var reqKey =te.getAttribute('data-req-key');
            var rqtKey =te.getAttribute('data-rqt-key');
            log("reqKey: ",reqKey);
            log("rqtKey: ",rqtKey);

            var targetPage;
            if ($(te).hasClass('view_cumulative')){
                targetPage = 2;
            }else if ($(te).hasClass('view_comments')){
                targetPage = 7;
            }else if ($(te).hasClass('view_report')){
                targetPage = 5;
            }                
            log("targetPage: ",targetPage);


            Promise = function(){
                return apex.server.process(
                            "CB_GET_TARGET_URL",
                            {   x01: targetPage,
                                x02: reqKey,
                                x03: rqtKey
                            }
                        );
                };       

            Promise()
                .then(function(data){
                        console.log("promise resolved", data);
                        if (!data.success){
                            log("Promise resolved. error: ", data.message);
                        }else{
                            if (targetPage == 5){
                                javascript:window.open(data.url, '_blank');    
                            }else{
                                apex.navigation.redirect(data.url);           
                            }
                        }
                    })
                .catch(showAjaxError);

        }        

        log(functionName, "End");
    },

    /**********************************************************************************************************************************
     * @function whenItemChange
     * @example cims_apex.cims.whenItemChange(this);
     * @desc   this function is called when  page load
     **********************************************************************************************************************************/                         
    module.whenItemChange = function(){
        functionName = 'cims_apex.cims.whenItemChange';        
        log(functionName,"Begin. pageNo: " + currentPageId, arguments);        
        var te = arguments[0].triggeringElement.id;           
        var teValue = apex.item(te).getValue();
        log('triggeringElement.id', te,teValue);
        if (te == "P6_TREE_LINK_KEY"){
            var pat_key = apex.item("P6_PAT_KEY").getValue();
            log("pat_key",pat_key);
            
            apex.item("P6_TREE_PAT_KEY").setValue(pat_key);            
            apex.region("clinical_notes_rn").refresh();
            apex.region("results_rn").refresh();
            
        }

        log(functionName, "End");
    },

    /**********************************************************************************************************************************
     * @function whenPageLoad
     * @example cims_apex.cims.whenPageLoad();
     * @desc   this function is called when  page load
     **********************************************************************************************************************************/                         
    module.whenPageLoad = function(){
        functionName = 'cims_apex.cims.whenPageLoad';        
        log(functionName,"Begin. pageNo: " + currentPageId, arguments);        
        if (currentPageId == 2){

        }        

        log(functionName, "End");
    },
  
   
    /**********************************************************************************************************************************
     * @function igInitialization
     * @example "cims_apex.cims.igInitialization" no parameters, no semicolon   
     * @desc   This function is called from IG initialization block, to set various properties.
     **********************************************************************************************************************************/
    module.igInitialization = function (config) {
        functionName = 'cims_apex.cims.igInitialization';        
        log(functionName,"Begin. pageNo: " + currentPageId, arguments);            

        //Tooltips apply to all pages
        config.defaultGridViewOptions = {
            tooltip: {
                content: function(callback, model, recordMeta, colMeta, columnDef ) {
                    var text = null;
                    if ( columnDef && recordMeta) {
                        if (currentPageId == 1){
                            if ( columnDef.property === "DPT_NAME" ) {
                                text = model.getValue( recordMeta.record, "DPT_NAME" ); 
                            }
                        }
                    }
                    return text;
                }
            }
        };   

        // Toolbar customization
        var $ = apex.jQuery;
        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar();        
        var toolbarGroup1 = toolbarData.toolbarFind("actions1");  
        
        
        // Logic apply to all pages
        toolbarGroup1.controls.unshift( {// Move Rows Per Page to toolbar
            type: "SELECT",
            action: "change-rows-per-page"
        } );     
        
        
        // save toolbar changes
        config.toolbarData = toolbarData;    


        if (currentPageId == 1){
            config.initActions = function( actions ) {
                actions.hide("show-columns-dialog");
                actions.hide("show-aggregate-dialog");
                
            }
        }        
        log(functionName, "End");

        return config;
    },
    /**********************************************************************************************************************************
     * @function igColumnInitialization
     * @example "cims_apex.cims.igColumnInitialization" no parameters, no semicolon   
     * @desc   This function is called from IG column initialization block, to set various properties.
     **********************************************************************************************************************************/    
    module.igColumnInitialization= function (config) {
        functionName = 'cims_apex.cims.columnInitialization';        
        log(functionName,"Begin. pageNo: " + currentPageId, arguments);                    
        var colStaticId = config.staticId;
        var colName = config.name;
        if (currentPageId == 1 ){            
            if (colName == 'VIEW_RESULT' || colName == 'VIEW_RESULT_POPUP'){
                config.defaultGridColumnOptions = {                
                    noHeaderActivate: true,
                    cellCssClassesColumn: "VIEW_RESULT_CLASS"
                };
            }else{                
                config.features = config.features || {};
                //config.features.sort = false;
                config.features.aggregate = false;                
            }    
             
        }
        log(functionName, "End");
        return config;
    };
   
    // Return public functions
    return module;
})(cims_apex.util, apex.jQuery); // pass in utils package
