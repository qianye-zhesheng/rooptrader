//+------------------------------------------------------------------+
//|                                               my_roop_ifdone.mq4 |
//|                                                           Qianye |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Qianye"
#property link      "https://www.mql5.com"
#property version   "1.02"
#property strict
//--- input parameters
input int      max_position;
input double   min_acceptable_rate;
input double   step;

//---preset values
#define DEFAULT_LOT 0.01;
#define DEFAULT_SLIPPAGE 3;

//---data storage
bool trade_aborted = false;


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
   
   if (trade_aborted) {
      Comment("trade aborted");
      return;
   }

   CircuitBreaker circuit_braker;   
   
   if (circuit_braker.NeedsToStopTrade()) {
      trade_aborted = true;
      Print("Trade is aborted due to loss cut");
      return;
   }
   
   BorderCrossing border_crossing;
   
   if (border_crossing.HasHappened()) {
      Order new_order = border_crossing.PrepareOrder();
      new_order.Execute();
   }
   
   
   
  }
//+------------------------------------------------------------------+





      
      
      
      
double Normalize(double value) {
   return NormalizeDouble(value, Digits());
}


enum RateTiming {
   CURRENT = 0,
   PREVIOUS = 1
};


class Rate {

private:
   double normalized_rate;

public:   
   
   Rate(const RateTiming timing) {
      normalized_rate = Normalize(iClose(Symbol(), PERIOD_M1, timing));
   }
   
   Rate(const double raw_rate) {
      normalized_rate = Normalize(raw_rate);
   }

   double GetValue() {
      return normalized_rate;
   }
   
   bool IsGreaterThan(Rate& another_rate) {
      return normalized_rate > another_rate.GetValue();
   }
   
   bool IsLessThan(Rate& another_rate) {
      return normalized_rate < another_rate.GetValue();
   }

};



class CircuitBreaker {

private:
   Rate current_rate;
   Rate trade_stop_rate;
   
public:
   CircuitBreaker():
      current_rate(RateTiming::CURRENT), trade_stop_rate(min_acceptable_rate) {}
   
   bool NeedsToStopTrade() {
      return current_rate.IsLessThan(trade_stop_rate);
   }
   
};



enum BorderRoundMethod {
   FLOOR = 0,
   CEIL = 1
};
   


class Border {

private:
   double border_value;
   
public:
   Border(Rate& rate, BorderRoundMethod round_method) {
      if(round_method == BorderRoundMethod::FLOOR) {
         border_value = Normalize(MathFloor(rate.GetValue() / step) * step);
      } else {
         border_value = Normalize(MathCeil(rate.GetValue() / step) * step);
      }
   }
   
   Border(double raw_value) {
      border_value = Normalize(raw_value);
   }
   
   Border(Border& border) {
      border_value = border.GetValue();
   }
   
   Border(Border* border_pointer) {
      border_value = border_pointer.GetValue();
   }
   
   double GetValue() {
      return border_value;
   }
   
   bool IsGreaterThan(Border& another_border) {
      return border_value > another_border.GetValue();
   }
   
   bool IsLessThan(Border& another_border) {
      return border_value < another_border.GetValue();
   }
   
   bool IsNotEqual(Border& another_border) {
      return IsGreaterThan(another_border) || IsLessThan(another_border);
   }
   
};






enum OrderResultType {
   SUCCESS = 0,
   FAILURE = 1,
   SKIPPED = 2
};


class Order {

private:
   Border current_border;
   
public:
   Order(Border* border_pointer): current_border(border_pointer) {}
      
   Order(Order& order): current_border(order.GetCurrentBorderPointer()) {}      
   
   Border* GetCurrentBorderPointer() {
      return GetPointer(current_border);
   }

   OrderResultType Execute() {
      
      if (HasValidationError()) {
         return OrderResultType::SKIPPED;
      }
      
      double lot = DEFAULT_LOT;
      int slippage = DEFAULT_SLIPPAGE;
      double stop_loss = GetStopLossRate();
      double profit_limit = GetProfitLimitRate();
      int identifier = GetOrderIdentifier();
      
      int ticket_no = OrderSend(Symbol(), OP_BUY, lot, Ask, slippage, stop_loss, profit_limit, NULL, identifier, 0, clrRed);
      
      return ticket_no == -1 ? OrderResultType::FAILURE : OrderResultType::SUCCESS;
   }
   
   bool HasValidationError() {
      if (ExistsSameBorderOrder()) {
         return true;
      }
      
      if (IsProfitLimitOnOrBelowCurrentPrice()) {
         return true;
      }
      
      return false;
   }
      

private:
   double GetStopLossRate() {
      double border = current_border.GetValue();
      double normal_limit = Normalize(border - step * max_position);
      if (normal_limit > Normalize(min_acceptable_rate)) {
         return normal_limit;
      }
      return min_acceptable_rate;
   }

   double GetProfitLimitRate() {
      return current_border.GetValue() + step;
   }
   
   int GetOrderIdentifier() {
      return (int)(current_border.GetValue() * 1000);
   }
   
   bool ExistsSameBorderOrder() {
      int order_count = OrdersTotal();
      int expecting_identifier = GetOrderIdentifier();
      
      for (int i = 0; i < order_count; i++) {
         bool isSelected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if (!isSelected) {
            continue;
         }
         int identifier = OrderMagicNumber();
         if (identifier == expecting_identifier) {
            return true;
         }
      }
      return false;   
   }
   
   bool IsProfitLimitOnOrBelowCurrentPrice() {
      double profit_limit = GetProfitLimitRate();
      double current_price = Normalize(Ask);
      return profit_limit <= current_price;
   }
};



class BorderCrossing {

private:
   Rate current_rate;
   Rate previous_rate;
   
   
public:
   BorderCrossing():
      current_rate(RateTiming::CURRENT), previous_rate(RateTiming::PREVIOUS) {}
   
   Border GetCurrentBorder() {
      return getBorder(current_rate);
   }
   
   Border GetPreviousBorder() {
      return getBorder(previous_rate);
   }
   
   bool HasHappened() {
      Border current_border = GetCurrentBorder();
      Border previous_border = GetPreviousBorder();
      return current_border.IsNotEqual(previous_border);
   }
   
   Order PrepareOrder() {
      Border border = GetCurrentBorder();
      
      // In order to avoid Border object left unreleased (compiler bug), pass the pointer of Border to Order constructor before deleting the pointer manually.
      Border* border_pointer = GetPointer(border);
      Order order(border_pointer);
      delete border_pointer;
      return order;
   }   

private:
   Border getBorder(Rate& rate) {
      if (current_rate.IsGreaterThan(previous_rate)) {
         return Border(rate, BorderRoundMethod::FLOOR);
      } else {
         return Border(rate, BorderRoundMethod::CEIL);
      }
   }
   
};

