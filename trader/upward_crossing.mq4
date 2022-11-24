#include "../base.mqh"


class UpwardCrossing: public CrossingType {

public:

   BorderRoundMethod GetBorderRoundMethod() override {
      return BorderRoundMethod::FLOOR;
   }
   
   Order* PrepareOrder(Border* border_pointer) override {
      Order* order = new BuyOrder(border_pointer);
      return order;
   }
      

};