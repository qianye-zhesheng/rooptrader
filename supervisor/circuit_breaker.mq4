#include "../base.mqh"

#include "account_info.mq4"

class CircuitBreaker {

private:
   AccountInfo account_info;
   
public:
   CircuitBreaker(): account_info() {}
   
   bool NeedsToStopTrade() {
      if (account_info.HasNoPosition()) {
         return false;
      }
      return IsBellowAcceptableMarginRatio();
   }

private:
   bool IsBellowAcceptableMarginRatio() {
      return account_info.GetMarginRatio() < MIN_ACCEPTABLE_MARGIN_RATIO;
   }
   
};
