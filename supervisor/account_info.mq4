#include "../base.mqh"


class AccountInfo {

private:
   int current_total;
   int equity;
   int required_margin;
   int free_margin;
   double margin_ratio;
   int position;

public:
   AccountInfo() {
      current_total = (int)AccountBalance();
      equity = (int)AccountEquity();
      free_margin = (int)AccountFreeMargin();
      required_margin = equity - free_margin;
      margin_ratio = (required_margin > 0) ? ((double)equity / (double)required_margin) * 100 : 0;
      position = OrdersTotal();
   }
   
   int GetCurrentTotal() {
      return current_total;
   }
   
   int GetFreeMargin() {
      return free_margin;
   }
   
   bool HasPosition() {
      return position > 0;
   }
   
   double GetMarginRatio() {
      return Normalize(margin_ratio);
   }
   
   int GetPositionCount() {
      return position;
   }
   
   bool HasNoPosition() {
      return position == 0;
   }
};