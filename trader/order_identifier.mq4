#include "../base.mqh"

#include "border.mq4"
#include "order_type.mq4"


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
   

private:
   int GetIntegerBorder() {
      return (int)(current_border.GetValue() * MathPow(10, Digits()));
   }      
};

const int OrderIdentifier::TOTAL_DIGIT      = 10000000;
const int OrderIdentifier::ORDER_TYPE_DIGIT =  1000000;