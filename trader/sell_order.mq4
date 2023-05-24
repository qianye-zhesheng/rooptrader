#include "../base.mqh"


class SellOrder: public Order {

private:
   Border current_border;
   
public:
   SellOrder(Border* border_pointer): current_border(border_pointer) {}
      
   OrderResultType Execute() {
      
      if (HasValidationError()) {
         return OrderResultType::SKIPPED;
      }
      
      double stop_loss = GetStopLossRate();
      double profit_limit = GetProfitLimitRate();
      int identifier = GetOrderIdentifier();
      
      int ticket_no = OrderSend(Symbol(), OP_SELL, DEFAULT_LOT, Bid, DEFAULT_SLIPPAGE, stop_loss, profit_limit, (string)identifier, identifier, 0, clrBlue);
      
      return ticket_no == -1 ? OrderResultType::FAILURE : OrderResultType::SUCCESS;
   }
   
   bool HasValidationError() {
      if (ExistsSameBorderOrder()) {
         return true;
      }
      
      if (IsProfitLimitOnOrAboveCurrentPrice()) {
         return true;
      }
      
      return false;
   }
      

private:
   double GetStopLossRate() {
      return BLANK_STOP_LOSS_RATE;
   }

   double GetProfitLimitRate() {
      return current_border.GetValue() - STEP;
   }
   
   int GetOrderIdentifier() {
      OrderIdentifier identifier(current_border, OrderType::SELL);
      return identifier.Generate();
   }
   
   bool ExistsSameBorderOrder() {
      return PositionScanner::ExistsPosition(GetOrderIdentifier());
   }
   
   bool IsProfitLimitOnOrAboveCurrentPrice() {
      double profit_limit = GetProfitLimitRate();
      double current_price = Normalize(Bid);
      return profit_limit >= current_price;
   }
};
