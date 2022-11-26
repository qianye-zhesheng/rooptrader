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
   
   static bool DoesExceedMaxPosition() {
      return GetOrderCount() >= MAX_POSITION;
   }
   
   static int GetOrderCount() {
      const int total_count = OrdersTotal();
      
      int prefix_matched_order_count = 0;
            
      for (int i = 0; i < total_count; i++) {
         bool isSelected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if (!isSelected) {
            continue;
         }
         int identifier = OrderMagicNumber();
         if (DoesPrefixMatch(identifier)) {
            prefix_matched_order_count++;
         }
      }
      return prefix_matched_order_count;
   }
   
private:
   static bool DoesPrefixMatch(int identifier) {
      return OrderIdentifier::DecodePrefix(identifier) == ORDER_IDENTIFIER_PREFIX;
   }

};