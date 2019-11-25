/* This file will only do the routing job based on some change done */
function handleTrigger(event) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  if( sheet.getName() == "Summary" ) {
    /* nothing to do as of now */
  }  
  else {
    /* autorun calculate() only when column F is edited */
    if( event != undefined && event.range.getColumn() != 6 ) {
      return;
    }
    else {
      /* do not run when columns are removed via macro */
      if( parseInt( PropertiesService.getScriptProperties().getProperty('flgColumnRemove') ) != 0 ) {
        PropertiesService.getScriptProperties().setProperty('flgColumnRemove', '0');
        return;
      }
    }
    /* all validation passed, now run the function */
    calculate(event);
  }
}
