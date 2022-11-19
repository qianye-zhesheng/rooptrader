//+------------------------------------------------------------------+
//|                                               my_roop_ifdone.mq4 |
//|                                                           Qianye |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Qianye"
#property link      "https://www.mql5.com"
#property version   "2.04"
#property strict
//--- input parameters
input int      max_position;
input double   min_acceptable_rate;
input double   step;
input int      order_identifier_prefix;

//---preset values
#define DEFAULT_LOT 0.01;
#define DEFAULT_SLIPPAGE 3;
const int report_hours[] = {7, 12, 17, 21};
const int ONE_HOUR = 3600;

//---data storage
bool trade_aborted = false;
int reported_account_total = 0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   if (IsMaxPositionOutOfRange(max_position)) {
      Alert("max_position shoud be between 1 and 99.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   if (IsMinRateOutOfRange(min_acceptable_rate)) {
      Alert("min_acceptable_rate shoud be positive.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   if (IsStepOutOfRange(step)) {
      Alert("step shoud be between 1 and 99.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   if (IsPrefixOutOfRange(order_identifier_prefix)) {
      Alert("order_identifier_prefix shoud be between 1 and 99.");
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
      Print("Trade is aborted due to loss cut");
      SendNotification("Trade is aborted due to loss cut");
      return;
   }
   
   BorderCrossing border_crossing;
   
   if (border_crossing.HasHappened()) {
      Order new_order = border_crossing.PrepareOrder();
      new_order.Execute();
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


double Normalize(double value) {
   return NormalizeDouble(value, Digits());
}

bool IsMaxPositionOutOfRange(int max_position_val) {
   return max_position_val < 1 || max_position_val > 99;
}

bool IsMinRateOutOfRange(double min_acceptable_rate_val) {
   return Normalize(min_acceptable_rate_val) <= 0;
}

bool IsStepOutOfRange(double step_val) {
   return Normalize(step_val) <= 0;
}

bool IsPrefixOutOfRange(int prefix) {
   return prefix < 1 || prefix > 99;
}

void DisplayParameters() {
   string parameters = "max_position: " + (string)max_position + "\n" +
      "min_acceptable_rate: " + DoubleToStr(min_acceptable_rate, 3) + "\n" +
      "step: " + DoubleToStr(step, 2)  + "\n" +
      "order_identifier_prefix: " + (string)order_identifier_prefix;
   Comment(parameters);
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
      return (int)(current_border.GetValue() * 1000) + order_identifier_prefix * 10000000;
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



class PerformanceReport {

private:
   int previous_total;
   int current_total;
   int equity;
   int required_margin;
   int free_margin;
   double margin_ratio;
   int position;

public:
   PerformanceReport(int previous_total_value) {
      previous_total = previous_total_value;
      current_total = (int)AccountBalance();
      equity = (int)AccountEquity();
      free_margin = (int)AccountFreeMargin();
      required_margin = equity - free_margin;
      margin_ratio = (required_margin > 0) ? ((double)equity / (double)required_margin) * 100 : 0;
      position = OrdersTotal();
   }
   
   void SendReport() {
      string message = GenerateMessage();
      SendNotification(message);
   }
   
   int GetCurrentTotal() {
      return current_total;
   }
   
   static bool IsNotTimeToSend() {
      return !IsTimeToSend();
   }
   
   
   static int fetchInitialTotal() {
      return (int)AccountBalance();
   }
   
private:
   string GenerateMessage() {
      return "total: " + (string)current_total + 
         " / diff: " + (string)(current_total - previous_total) +
         " / margin: " + (string)free_margin +
         " / ratio: " + DoubleToStr(margin_ratio, 1) + "%" +
         " / orders: " + (string)position;
   }
   
   static bool IsTimeToSend() {
      MqlDateTime date_time;
      TimeToStruct(LocalTime(), date_time);
      int current_hour = date_time.hour;
      
      for (int i = 0; i < ArraySize(report_hours); i++) {
         int hour = report_hours[i];

         if (hour == current_hour) {
            return true;
         }
      }
      return false;
   }
   
};




