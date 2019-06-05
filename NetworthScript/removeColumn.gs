function removeColumn() {
  /* local variables used across the function */
  var sheet = SpreadsheetApp.getActive();
  var maxRows = PropertiesService.getScriptProperties().getProperty('MAX_ROWS');  
  
  /* validations */
  if(maxRows == null) {
    Browser.msgBox("Please define MAX_ROWS in project properties inside script editor");
    return;
  }
  
  /* remove two columns */
  sheet.getRange('E:F').deleteCells(SpreadsheetApp.Dimension.COLUMNS);
    
  /* adjust the principle */
  var arrOri = sheet.getRange("C4:C" + maxRows).getValues();
  var arrCas = sheet.getRange("B4:B" + maxRows).getValues();
  var arrPrinciple = new Array();
  for(var i=0; i<arrOri.length; i++) {
    if( arrOri[i] != "" ) {
      
      /* adjust the principle based on additon or removal of funds */
      var cas = arrCas[i] == "" ? "NONE" : arrCas[i].toString().split("_")[0];
      switch(cas) {
        case "NONE":
          var arr = new Array();
          arr.push(arrOri[i]);
          arrPrinciple.push(arr);             
          break;
          
        case "REM":
          var arr = new Array();
          arr.push( parseInt(arrOri[i]) + parseInt(arrCas[i].toString().split("_")[1]) );
          arrPrinciple.push(arr);             
          break;
          
        case "ADD":
          var arr = new Array();
          arr.push( parseInt(arrOri[i]) - parseInt(arrCas[i].toString().split("_")[1]) );
          arrPrinciple.push(arr);             
          break;

        default:
          Browser.msgBox("something wrong in 'Action' field");
      }
    }
    else {
      var arr = new Array();
      arr.push("");
      arrPrinciple.push(arr);      
    }
  }
  sheet.getRange("C4:C" + maxRows).setValues(arrPrinciple);
  
  /* finalization */
  sheet.getRange('F4').activate();
  PropertiesService.getScriptProperties().setProperty('flgColumnRemove', '1');
}
