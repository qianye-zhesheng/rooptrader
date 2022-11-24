#include "../base.mqh"

#include "order_result_type.mq4"


class Order {
public:
   virtual OrderResultType Execute() = 0;
};