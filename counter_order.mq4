//+------------------------------------------------------------------+
//|                                                counter_order.mq4 |
//|                                                           Qianye |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Qianye"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int last_ordered_day = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double lot = 0.01;
   int slippage = 10;
   double stop_loss = Bid + 0.5;
   double profit_limit = Bid - 5;
   int identifier = 111;
   //double macd_threshold = 0.07;
   //double ma_threshold = 0;
   //double macd_max = 0.5;
   //double macd_diff = 0.08;


   double macd_current = Normalize(iMACD(Symbol(),PERIOD_D1,19,39,9,PRICE_CLOSE,MODE_MAIN,0));
   double macd_previous = Normalize(iMACD(Symbol(),PERIOD_D1,19,39,9,PRICE_CLOSE,MODE_MAIN,1));
   double macd_previous2 = Normalize(iMACD(Symbol(),PERIOD_D1,19,39,9,PRICE_CLOSE,MODE_MAIN,2));
   
   double signal_current = Normalize(iMACD(Symbol(),PERIOD_D1,19,39,9,PRICE_CLOSE,MODE_SIGNAL,0));
   double signal_previous = Normalize(iMACD(Symbol(),PERIOD_D1,19,39,9,PRICE_CLOSE,MODE_SIGNAL,1));
   double signal_previous2 = Normalize(iMACD(Symbol(),PERIOD_D1,19,39,9,PRICE_CLOSE,MODE_SIGNAL,2));
   
   double move_average5_current = Normalize(iMA(Symbol(), PERIOD_D1, 5, 0, MODE_SMA, PRICE_CLOSE, 0));
   double move_average5_previous = iMA(Symbol(), PERIOD_D1, 5, 0, MODE_SMA, PRICE_CLOSE, 1);
   
   double move_average25_current = Normalize(iMA(Symbol(), PERIOD_D1, 25, 0, MODE_SMA, PRICE_CLOSE, 0));
   double move_average25_previous = iMA(Symbol(), PERIOD_D1, 25, 0, MODE_SMA, PRICE_CLOSE, 1);
   
   double move_average60_current = Normalize(iMA(Symbol(), PERIOD_D1, 60, 0, MODE_SMA, PRICE_CLOSE, 0));
   double move_average60_previous = iMA(Symbol(), PERIOD_D1, 60, 0, MODE_SMA, PRICE_CLOSE, 1);


   
   int ticket_waiting = SelectTicketNo();
   

   
   if (ticket_waiting > 0) {
      if (macd_previous < signal_previous && macd_current > signal_current) {
         int ticket_closed = OrderClose(ticket_waiting, lot,Ask, slippage, clrAliceBlue);
         return;
      }
      return;
   }
   

   if (macd_previous > signal_previous && macd_current < signal_current && move_average5_previous > move_average5_current) {
   
   
      if (last_ordered_day == Year() * 1000 + Month() * 100 + Day()) {
         return;
      }
      int ticket_ordered = OrderSend(Symbol(), OP_SELL, lot, Bid, slippage, stop_loss, profit_limit, NULL, identifier, 0, clrRed);
      last_ordered_day = Year() * 1000 + Month() * 100 + Day();
   }
   
  }
//+------------------------------------------------------------------+


double Normalize(double value) {
   return NormalizeDouble(value, Digits());
}


int SelectTicketNo() {
   int order_count = OrdersTotal();
   int expecting_identifier = 111;
   
   for (int i = 0; i < order_count; i++) {
      bool isSelected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (!isSelected) {
         continue;
      }
      int identifier = OrderMagicNumber();
      if (identifier == expecting_identifier) {
         return OrderTicket();
      }
   }
   return -1;   
}