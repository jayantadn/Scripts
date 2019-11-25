/* The Fund Object */
function Fund() {
  this.name = null;
  this.bgcolor = null;
  this.profit = null;
  this.sd = null;
}

/* The main function */
function showSummary() {
  /* get the current sheet */
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  
  /* local variables */
  var arrFunds = [];
  var document = SpreadsheetApp.getActiveSpreadsheet();
  var maxRows = PropertiesService.getScriptProperties().getProperty('MAX_ROWS');
  var maxCols = PropertiesService.getScriptProperties().getProperty('MAX_COLS');
  
  /* loop through each sheet and accumulate all the funds */
  for(var idxSheet=0; idxSheet < document.getNumSheets(); idxSheet++) {
    var sheet = document.getSheets()[idxSheet];
    
    /* skip the summary sheet */
    if( sheet.getName() == "Summary") {
      continue;
    }
    
    /* loop through each fund and add if applicable */
    var arrFundNames = sheet.getRange("A4:A" + maxRows).getValues();
    var arrFundBgColor = sheet.getRange("A4:A" + maxRows).getBackgrounds();
    var arrFundProfit = sheet.getRange("D4:D" + maxRows).getValues();
    arrFundNames.forEach( function(name, idx) {
      if(name[0] !== "" && arrFundProfit[idx][0] !== "") {
        var fund = new Fund();
        var arrData = sheet.getRange(4+idx, 5, 1, maxCols);

        /* copy the basic elements */
        fund.name = name;
        fund.bgcolor = arrFundBgColor[idx];
        fund.profit = arrFundProfit[idx];
        
        /* calculate Standard Deviation */
        var arrValData = arrData.getValues(); // 2dim
        var arrValProfit = arrValData[0].filter( function(data, idx) { // 1dim
          return !(idx%2); 
        } ); 
        arrValProfit = arrValProfit.map( function(val) { return val*100000; } ); // upscaling
        var mean = arrValProfit.reduce(function (a, b) {
          return Number(a) + Number(b);
        }) / arrValProfit.length;
        var sd = Math.sqrt(arrValProfit.reduce(function (sq, n) {
            return sq + Math.pow(n - mean, 2);
        }, 0) / (arrValProfit.length - 1));
        arr = [sd/100000]; // downscaling back
        fund.sd = arr;
                
        /* add to array */
        arrFunds.push(fund);
      }
    });
  }

  /* now we have a list of funds. time to sort them by profit */
  arrFunds.sort( function(fund1, fund2) {
    return fund2.profit[0] - fund1.profit[0];
  });
  
  /* Print funds to the sheet */
  var sheet = document.getSheetByName("Summary");
  sheet.getRange(4, 2, arrFunds.length, 1).setValues( arrFunds.map( function(fund) { return fund.name; } ) );
  sheet.getRange(4, 2, arrFunds.length, 1).setBackgrounds( arrFunds.map( function(fund) { return fund.bgcolor; } ) );
  sheet.getRange(4, 3, arrFunds.length, 1).setValues( arrFunds.map( function(fund) { return fund.profit; } ) );
  sheet.getRange(4, 4, arrFunds.length, 1).setValues( arrFunds.map( function(fund) { return fund.sd; } ) );
}