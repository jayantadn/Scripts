function addColumn() {
  /* local variables used across the function */
  var sheet = SpreadsheetApp.getActive();
  var maxRows = PropertiesService.getScriptProperties().getProperty('MAX_ROWS');  
  
  /* validations */
  if(maxRows == null) {
    Browser.msgBox("Please define MAX_ROWS in project properties inside script editor");
    return;
  }
  
  /* insert two columns */
  sheet.getRange('E:F').activate();
  sheet.getActiveSheet().insertColumnsBefore(sheet.getActiveRange().getColumn(), 2);
  sheet.getRange('E4:F' + maxRows).clearFormat();
  sheet.getRange("E:E").activate();
  sheet.getActiveSheet().setColumnWidth(5, 65);
  sheet.getRange("F:F").activate();
  sheet.getActiveSheet().setColumnWidth(6, 75);
    
  /* insert today's date */
  sheet.getRange('E1:F1').activate()
  .mergeAcross();
  sheet.getActiveRangeList().setHorizontalAlignment('center');
  var date = new Date();
  date.setHours(0, 0, 0, 0);
  sheet.getActiveRangeList().setValue(date);
  
  /* format current networth */
  sheet.getRange('F2').activate();
  sheet.getActiveRangeList().setNumberFormat('[$?][>9999999]##\\,##\\,##\\,##0;[$?][>99999]##\\,##\\,##0;[$?]##,##0');
  
  /* format the new column */
  sheet.getRange('F4:F' + maxRows).activate();
  sheet.getActiveRangeList().setNumberFormat('[$?][>9999999]##\\,##\\,##\\,##0;[$?][>99999]##\\,##\\,##0;[$?]##,##0');
  sheet.getRange('F:F').setBorder(null, null, null, true, null, null, '#000000', SpreadsheetApp.BorderStyle.SOLID);

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
          arr.push( parseInt(arrOri[i]) - parseInt(arrCas[i].toString().split("_")[1]) );
          arrPrinciple.push(arr);             
          break;
          
        case "ADD":
          var arr = new Array();
          arr.push( parseInt(arrOri[i]) + parseInt(arrCas[i].toString().split("_")[1]) );
          arrPrinciple.push(arr);             
          break;

        default:
          alert("something wrong in 'Action' field");
      }
    }
    else {
      var arr = new Array();
      arr.push("");
      arrPrinciple.push(arr);      
    }
  }
  sheet.getRange("C4:C" + maxRows).setValues(arrPrinciple);
  
  /* reset all selection */
  sheet.getRange('F4').activate();
}
