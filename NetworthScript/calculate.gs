function calculate(e) { 
  /* get the current sheet */
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  
  /* initialize variables */
  var maxRows = PropertiesService.getScriptProperties().getProperty('MAX_ROWS');
  var arrNew = sheet.getRange("F4:F" + maxRows).getValues();
  var arrOld = sheet.getRange("H4:H" + maxRows).getValues();
  var arrOri = sheet.getRange("C4:C" + maxRows).getValues();
  var arrCas = sheet.getRange("B4:B" + maxRows).getValues();
  
  /* validations */
  if(maxRows == null) {
    Browser.msgBox("Please define MAX_ROWS in project properties inside script editor");
    return;
  }
  
  /* all calculations */
  var arrDeltaProfit = []; // this becomes a 2dim array, when value is populated
  var arrTotalProfit = []; // this becomes a 2dim array, when value is populated
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
      
      /* total profit */
      var totalProfit = (arrNew[i] - arrOri[i]) / arrOri[i]; // this is not the same as overall total profit
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
  
  /* highlight min/max cell */
  showMinMax(5); // delta
  showMinMax(4); // total
  
  /* highlight in-plausible values */
  showErrors();
}


function showMinMax(col) {
  /* scope local variables */
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  var maxRows = PropertiesService.getScriptProperties().getProperty('MAX_ROWS');
  sheet.getRange( 4, col, maxRows, 1).setFontColor("black");
  
  /* the actual calculation */
  var rangeProfit = sheet.getRange(4, col, maxRows, 1);
  var arrProfit = rangeProfit.getValues().map( function(data) { return data[0]; } );
  if(sheet.getRange(2, col).getValue() > 0) {
    var max = arrProfit.concat().sort( function(a,b) { return a-b; } )[arrProfit.length-1];
    var idx = arrProfit.indexOf(max);
    sheet.getRange(4+idx, col).setFontColor("green");
  }
  else {
    var arrProfitFiltered = arrProfit.filter( function(data) { return data != ""; } );
    var min = arrProfitFiltered.concat().sort( function(a,b) { return a-b; } )[0];
    var idx = arrProfit.indexOf(min);
    sheet.getRange(4+idx, col).setFontColor("red");
  }
}


function showErrors() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  var maxRows = PropertiesService.getScriptProperties().getProperty('MAX_ROWS');
  var rangeProfit = sheet.getRange(4, 5, maxRows, 1);
  var arrProfit = rangeProfit.getValues().map( function(data) { return data[0]; } );
  var arrErr = [];
  arrProfit.forEach( function(data, idx) {
    if( Math.abs(data) > 0.1 )
      arrErr.push(idx);
  });
  arrErr.forEach( function(idx) {
    sheet.getRange(4+idx, 5).setFontColor("#cc00cc");
  });
}
