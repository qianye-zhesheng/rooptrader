#include "../base.mqh"


class DownwardCrossing: public CrossingType {

public:

   BorderRoundMethod GetBorderRoundMethod() override {
      return BorderRoundMethod::CEIL;
   }
   
   Order* PrepareOrder(Border* border_pointer) override {
      Order* order = new SellOrder(border_pointer);
      return order;
   }

};