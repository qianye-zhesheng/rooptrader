#include "../base.mqh"

#include "border.mq4"


class OrderIdentifier {

private:
   static const int TOTAL_DIGIT;
   static const int ORDER_TYPE_DIGIT;
   Border current_border;
   OrderType order_type;

public:
   OrderIdentifier (Border& border, OrderType order_type_value): current_border(border) {
      order_type = order_type_value;
   }

   int Generate() {
      return ORDER_IDENTIFIER_PREFIX * TOTAL_DIGIT + order_type * ORDER_TYPE_DIGIT + GetIntegerBorder();
   }
   
   static int DecodePrefix(int identifier) {
      return (int)MathFloor(identifier / TOTAL_DIGIT);
   }
   
   static OrderType DecodeOrderType(int identifier) {
      const int order_type_value = 
         (int)MathFloor((identifier - ORDER_IDENTIFIER_PREFIX * TOTAL_DIGIT) / ORDER_TYPE_DIGIT);
         
      return (OrderType)order_type_value;
   }
   
   static bool HasMatchedPrefix(int identifier) {
      return OrderIdentifier::DecodePrefix(identifier) == ORDER_IDENTIFIER_PREFIX;
   }
   
   static bool DoesNotHaveMatchedPrefix(int identifier) {
      return !HasMatchedPrefix(identifier);
   }
   

private:
   int GetIntegerBorder() {
      return (int)(current_border.GetValue() * MathPow(10, Digits()));
   }      
};

const int OrderIdentifier::TOTAL_DIGIT      = 10000000;
const int OrderIdentifier::ORDER_TYPE_DIGIT =  1000000;