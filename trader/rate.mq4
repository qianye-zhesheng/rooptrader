#include "../base.mqh"

#include "rate_timing.mq4"

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
