#include "../base.mqh"


class OrderLimiter {

private:
   OrderType order_type;

public:
   OrderLimiter(const OrderType placing_order_type) {
      order_type = placing_order_type;
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
