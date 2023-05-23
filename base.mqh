#property copyright "Qianye"
#property link      "https://www.mql5.com"
#property version   "3.01"
#property strict

#include "common.mqh"


//--- input parameters
input double STEP;
input int MAX_POSITION;
input double MIN_ACCEPTABLE_RATE;
input double MAX_ACCEPTABLE_RATE;
input int ORDER_IDENTIFIER_PREFIX;
input bool ORDER_LIMIT_ENABLED;
input OrderType ORDER_LIMIT_TARGET;
input int ACCEPTABLE_MAX_ORDER_DIFF;




//---preset values
const double DEFAULT_LOT = 0.01;
const int DEFAULT_SLIPPAGE = 3;
const int REPORT_HOURS[] = {7, 12, 17, 21};
const int ONE_HOUR = 3600;
const double MIN_ACCEPTABLE_MARGIN_RATIO = 200;
const double BLANK_STOP_LOSS_RATE = 0;



