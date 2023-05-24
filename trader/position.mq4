#include "../base.mqh"

class Position {

private:
   int identifier;
   OrderType order_type;
   
public:
   Position(const int identifier_val, const OrderType order_type_val) {
      identifier = identifier_val;
      order_type = order_type_val;
   }
   
   Position(Position& position) {
      identifier = position.GetIdentifier();
      order_type = position.GetOrderType();
   }
   
   int GetIdentifier() {
      return identifier;
   }
   
   OrderType GetOrderType() {
      return order_type;
   }
   
   bool IsBuyOrder() {
      return order_type == OrderType::BUY;
   }
   
   bool IsSellOrder() {
      return order_type == OrderType::SELL;
   }

};