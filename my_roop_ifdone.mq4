//+------------------------------------------------------------------+
//|                                               my_roop_ifdone.mq4 |
//|                                                           Qianye |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "base.mqh"
#include "module.mqh"


//---data storage
bool trade_aborted = false;
int reported_account_total = 0;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    
   if (IsStepOutOfRange(STEP)) {
      Alert("STEP shoud be positive.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   if (IsMaxPositionOutOfRange(MAX_POSITION)) {
      Alert("MAX_POSITION shoud be between 1 and 99.");
      return(INIT_PARAMETERS_INCORRECT);
   }

   if (IsRateOutOfRange(MIN_ACCEPTABLE_RATE)) {
      Alert("MIN_ACCEPTABLE_RATE should be positive.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   if (IsRateOutOfRange(MAX_ACCEPTABLE_RATE)) {
      Alert("MAX_ACCEPTABLE_RATE should be positive.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   if (IsPrefixOutOfRange(ORDER_IDENTIFIER_PREFIX)) {
      Alert("ORDER_IDENTIFIER_PREFIX shoud be between 1 and 99.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   DisplayParameters();
   
   reported_account_total = PerformanceReport::fetchInitialTotal();
   
   EventSetTimer(ONE_HOUR);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
   if (trade_aborted) {
      Comment("trade aborted");
      return;
   }

   CircuitBreaker circuit_braker;   
   
   if (circuit_braker.NeedsToStopTrade()) {
      trade_aborted = true;
      Print("Trade is aborted due to avoid loss cut");
      SendNotification("Trade is aborted due to avoid loss cut");
      return;
   }
   
   if (OrderFinder::DoesExceedMaxPosition()) {
      return;
   }
   
   BorderCrossing border_crossing;
   
   if (border_crossing.HasHappened()) {
      Order* new_order = border_crossing.PrepareOrder();
      new_order.Execute();
      delete new_order;
   }
   
   
   
  }
//+------------------------------------------------------------------+


void OnTimer() {

   if (PerformanceReport::IsNotTimeToSend()) {
      return;
   }
   
   PerformanceReport performance_report(reported_account_total);
   performance_report.SendReport();
   
   reported_account_total = performance_report.GetCurrentTotal();
   
}


