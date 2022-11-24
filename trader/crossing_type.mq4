#include "../base.mqh"


class CrossingType {
public:
   virtual BorderRoundMethod GetBorderRoundMethod() = 0;
   virtual Order* PrepareOrder(Border* border_pointer) = 0;
};