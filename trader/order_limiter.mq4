#include "../base.mqh"


class OrderLimiter {

private:
   OrderType order_type;

public:
   OrderLimiter(OrderType order_type_value) {
      order_type = order_type_value;
   }
   
   bool IsFired() {
      if (IsDisabled()) {
         return false;
      }
      
      if (IsNotTargetOrderType()) {
         return false;
      }
      
      if (order_type == OrderType::BUY) {
         return PositionScanner::ReachedBuyOrderLimit();
      }
      
      return PositionScanner::ReachedSellOrderLimit();
   }
   
private:
   bool IsDisabled() {
      return !ORDER_LIMIT_ENABLED;
   }
   
   bool IsNotTargetOrderType() {
      return order_type != ORDER_LIMIT_TARGET;
   }


};
