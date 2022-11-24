#include "../base.mqh"

#include "border_round_method.mq4"
#include "rate.mq4"

class Border {

private:
   double border_value;
   
public:
   Border(Rate& rate, BorderRoundMethod round_method) {
      if(round_method == BorderRoundMethod::FLOOR) {
         border_value = Normalize(MathFloor(rate.GetValue() / STEP) * STEP);
      } else {
         border_value = Normalize(MathCeil(rate.GetValue() / STEP) * STEP);
      }
   }
   
   Border(double raw_value) {
      border_value = Normalize(raw_value);
   }
   
   Border(Border& border) {
      border_value = border.GetValue();
   }
   
   Border(Border* border_pointer) {
      border_value = border_pointer.GetValue();
   }
   
   double GetValue() {
      return border_value;
   }
   
   bool IsGreaterThan(Border& another_border) {
      return border_value > another_border.GetValue();
   }
   
   bool IsLessThan(Border& another_border) {
      return border_value < another_border.GetValue();
   }
   
   bool IsNotEqual(Border& another_border) {
      return IsGreaterThan(another_border) || IsLessThan(another_border);
   }
   
};
