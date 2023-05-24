#include "../base.mqh"

class PositionList {

private:
   Position position_list[];
   int size;

public:
   PositionList() {
   
      // Resize the array here because it is unable to specify the array size at the declaration.
      ArrayResize(position_list, MAX_POSITION);
   
      const int total_count = OrdersTotal();
      
      int array_index = 0;
                
      for (int i = 0; i < total_count; i++) {
         const bool isSelected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (!isSelected) {
            continue;
         }
         
         const int identifier = OrderMagicNumber();         
         if (OrderIdentifier::DoesNotHaveMatchedPrefix(identifier)) {
            continue;
         }
         
         // Fetch the original order type from the identifier because OrderType() returns the opposite type.       
         Position* position = new Position(identifier, OrderIdentifier::DecodeOrderType(identifier));
         position_list[array_index] = position;
         array_index++;
                
         // Delete the pointer to avoid the memory leak.
         delete position;
      }
      
      size = array_index;
   }
   
  
   
   int GetSize() {
      return size;
   }
   
   bool Contains(int identifier) {
      for(int i = 0; i < size; i++) {
         Position position = position_list[i];
         if (position.GetIdentifier() == identifier) {
            return true;
         }
      }
      return false;
   }
   
   int GetBuyCount() {
      int buy_count = 0;
      for(int i = 0; i < size; i++) {
         Position position = position_list[i];
         if (position.IsBuyOrder()) {
            buy_count++;
         }
      }
      return buy_count;
   }
   
   int GetSellCount() {
      int sell_count = 0;
      for(int i = 0; i < size; i++) {
         Position position = position_list[i];
         if (position.IsSellOrder()) {
            sell_count++;
         }
      }
      return sell_count;
   }
   
   int BuyCountMinusSellCount() {
      return GetBuyCount() - GetSellCount();
   }
   
   int SellCountMinusBuyCount() {
      return GetSellCount() - GetBuyCount();
   }
};

