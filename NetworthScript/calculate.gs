function calculate(e) {
  /* autorun this function only when column F is edited */
  if( e != undefined && e.range.getColumn() != 6 ) {
    return;
  }
  else {
    /* do not run when columns are removed via macro */
    if( parseInt( PropertiesService.getScriptProperties().getProperty('flgColumnRemove') ) != 0 ) {
      PropertiesService.setScriptProperties().setProperty('flgColumnRemove', '0');
      return;
    }
  }
  
  /* local variables */
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheets()[1];
  var maxRows = PropertiesService.getScriptProperties().getProperty('MAX_ROWS');
  var arrNew = sheet.getRange("F4:F" + maxRows).getValues();
  var arrOld = sheet.getRange("H4:H" + maxRows).getValues();
  var arrOri = sheet.getRange("C4:C" + maxRows).getValues();
  var arrCas = sheet.getRange("B4:B" + maxRows).getValues();
  var profitTotalDelta = sheet.getRange("E2").getValue();
  
  /* validations */
  if(maxRows == null) {
    Browser.msgBox("Please define MAX_ROWS in project properties inside script editor");
    return;
  }
  
  /* all calculations */
  var arrDeltaProfit = new Array();
  var arrTotalProfit = new Array();
  var valOld = 0;
  var sumOld = 0;
  var iMinMax = null;
  for(var i=0; i<arrNew.length; i++) {
    /* WARNING! do not read/write any cell directly inside the loop. */
    /* proceed only if there is a new entry */
    if( arrNew[i] != "" ) {
      
      /* for new investment, old value is going to be empty. converting those cases to 0. */
      if(arrOld[i] == "") {
        arrOld[i] = 0
      }

      /* adjust the old value any addition or removal of investment */
      var cas = arrCas[i] == "" ? "NONE" : arrCas[i].toString().split("_")[0];
      switch(cas) {
        case "NONE":
          valOld = arrOld[i];
          break;
          
        case "REM":
          valOld = parseInt(arrOld[i]) - parseInt( arrCas[i].toString().split("_")[1] );
          break;
          
        case "ADD":
          valOld = parseInt(arrOld[i]) + parseInt( arrCas[i].toString().split("_")[1] );
          break;

        default:
          alert("something wrong in 'Action' field");
      }

      /* adjust the old principle, to calculate total delta profit% */
      sumOld = sumOld + parseInt(valOld);
            
      /* delta profit */
      var deltaProfit = (arrNew[i] - valOld) / valOld;
      var arr = new Array(); // gscript expects a 2D array here
      arr.push(deltaProfit);
      arrDeltaProfit.push(arr);
      
      /* calculate the min/max delta profit */
      if( iMinMax == null ) {
        iMinMax = i;
      }
      else {
        if( profitTotalDelta > 0 ) {
          if( arrDeltaProfit[i][0] > arrDeltaProfit[iMinMax][0] ) {
            iMinMax = i;
          }
        }
        else {
          Logger.log( arrDeltaProfit[i] );
          if( arrDeltaProfit[i][0] < arrDeltaProfit[iMinMax][0] ) {
            iMinMax = i;
          }
        }
      }
           
      /* total profit */
      var totalProfit = (arrNew[i] - arrOri[i]) / arrOri[i];
      var arr = new Array(); // gscript expects a 2D array here
      arr.push(totalProfit);
      arrTotalProfit.push(arr);      
    }
    else {
      var arr = new Array();
      arr.push("");
      arrDeltaProfit.push(arr);
      arrTotalProfit.push(arr);
    }
  }
  
  /* set the calculated values in corresponding fields */
  sheet.getRange("F2").setFormula("=sum(F4:F" + maxRows + ")"); // current networth
  sheet.getRange("E2").setValue( (sheet.getRange("F2").getValue() - sumOld) / sumOld); // total delta profit %
  sheet.getRange("E4:E" + maxRows).setValues(arrDeltaProfit); // delta profit % for individual funds
  sheet.getRange("D4:D" + maxRows).setValues(arrTotalProfit); // total profit % for individual funds
  
  /* highlight the min/max cell */
  sheet.getRange( 4, 5, maxRows, 1).setFontColor("black");
  if( profitTotalDelta > 0 ) { /* CAVEAT! by this time profitTotalDelta might have changed. but its safe to ignore this. */
    sheet.getRange( 4 + iMinMax, 5).setFontColor("green");
  }
  else {
    sheet.getRange( 4 + iMinMax, 5).setFontColor("red");
  }
}