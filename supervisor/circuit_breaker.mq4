#include "../base.mqh"

#include "account_info.mq4"
#include "../trader/rate.mq4"

class CircuitBreaker {

private:
   AccountInfo account_info;
   Rate current_rate;
   Rate trade_stop_max_rate;
   Rate trade_stop_min_rate;
   
public:
   CircuitBreaker(): 
      account_info(),
      current_rate(RateTiming::CURRENT),
      trade_stop_max_rate(MAX_ACCEPTABLE_RATE),
      trade_stop_min_rate(MIN_ACCEPTABLE_RATE) {}
   
   bool NeedsToStopTrade() {
      if (account_info.HasNoPosition()) {
         return false;
      }
      
      if (IsBellowAcceptableMarginRatio()) {
         return true;
      }
      
      if (current_rate.IsLessThan(trade_stop_min_rate)) {
         return true;
      }
      
      if (current_rate.IsGreaterThan(trade_stop_max_rate)) {
         return true;
      }
      
      return false;
   }

private:
   bool IsBellowAcceptableMarginRatio() {
      return account_info.GetMarginRatio() < MIN_ACCEPTABLE_MARGIN_RATIO;
   }
   
};
