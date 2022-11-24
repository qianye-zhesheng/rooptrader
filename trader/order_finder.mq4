#include "../base.mqh"


class OrderFinder {

public:
   static bool ExistsOrder(int identifier) {
      int order_count = OrdersTotal();
      int expecting_identifier = identifier;
      
      for (int i = 0; i < order_count; i++) {
         bool isSelected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if (!isSelected) {
            continue;
         }
         int existing_identifier = OrderMagicNumber();
         if (existing_identifier == expecting_identifier) {
            return true;
         }
      }
      return false;
   }

};