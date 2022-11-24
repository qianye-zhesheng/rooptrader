#property copyright "Qianye"
#property link      "https://www.mql5.com"
#property version   "3.00"
#property strict

#include "common.mqh"


//--- input parameters
input double STEP;
input double STOP_LOSS_STEP;
input int ORDER_IDENTIFIER_PREFIX;



//---preset values
const double DEFAULT_LOT = 0.01;
const int DEFAULT_SLIPPAGE = 3;
const int REPORT_HOURS[] = {7, 12, 17, 21};
const int ONE_HOUR = 3600;
const double MIN_ACCEPTABLE_MARGIN_RATIO = 200;



