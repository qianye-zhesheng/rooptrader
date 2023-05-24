#include "../base.mqh"


class BuyOrder: public Order {

private:
   Border current_border;
   
public:
   BuyOrder(Border* border_pointer): current_border(border_pointer) {}
      
   OrderResultType Execute() {
      
      if (HasValidationError()) {
         return OrderResultType::SKIPPED;
      }
      
      double stop_loss = GetStopLossRate();
      double profit_limit = GetProfitLimitRate();
      int identifier = GetOrderIdentifier();
      
      int ticket_no = OrderSend(Symbol(), OP_BUY, DEFAULT_LOT, Ask, DEFAULT_SLIPPAGE, stop_loss, profit_limit, (string)identifier, identifier, 0, clrRed);
      
      return ticket_no == -1 ? OrderResultType::FAILURE : OrderResultType::SUCCESS;
   }
   
   bool HasValidationError() {
   
      if (ExistsSameBorderOrder()) {
         return true;
      }
      
      if (IsProfitLimitOnOrBelowCurrentPrice()) {
         return true;
      }
            
      return false;
   }
      

private:
   double GetStopLossRate() {
      return BLANK_STOP_LOSS_RATE;
   }

   double GetProfitLimitRate() {
      return current_border.GetValue() + STEP;
   }
   
   int GetOrderIdentifier() {
      OrderIdentifier identifier(current_border, OrderType::BUY);
      return identifier.Generate();
   }
   
   bool ExistsSameBorderOrder() {
      return PositionScanner::ExistsPosition(GetOrderIdentifier());
   }
   
   bool IsProfitLimitOnOrBelowCurrentPrice() {
      double profit_limit = GetProfitLimitRate();
      double current_price = Normalize(Ask);
      return profit_limit <= current_price;
   }
};
