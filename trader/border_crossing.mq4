#include "../base.mqh"

#include "order.mq4"
#include "crossing_type.mq4"


class BorderCrossing {

private:
   Rate current_rate;
   Rate previous_rate;
   CrossingType* crossing_type;
   
   
public:
   BorderCrossing():
      current_rate(RateTiming::CURRENT), previous_rate(RateTiming::PREVIOUS) {
         if (current_rate.IsGreaterThan(previous_rate)) {
            crossing_type = new UpwardCrossing();
         } else {
            crossing_type = new DownwardCrossing();
         }
      }
   
   ~BorderCrossing() {
      delete crossing_type;
   }
   
   Border GetCurrentBorder() {
      return getBorder(current_rate);
   }
   
   Border GetPreviousBorder() {
      return getBorder(previous_rate);
   }
   
   bool HasHappened() {
      Border current_border = GetCurrentBorder();
      Border previous_border = GetPreviousBorder();
      return current_border.IsNotEqual(previous_border);
   }
   
   Order* PrepareOrder() {
      Border border = GetCurrentBorder();
      
      // In order to avoid Border object left unreleased (compiler bug), pass the pointer of Border to Order constructor before deleting the pointer manually.
      Border* border_pointer = GetPointer(border);
      Order* order_pointer = crossing_type.PrepareOrder(border_pointer);
      delete border_pointer;
      return order_pointer;
   }   

private:
   Border getBorder(Rate& rate) {
      return Border(rate, crossing_type.GetBorderRoundMethod());
   }
   
};

