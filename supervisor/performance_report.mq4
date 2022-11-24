#include "../base.mqh"

#include "account_info.mq4"


class PerformanceReport {

private:
   AccountInfo account_info;
   int previous_total;

public:
   PerformanceReport(int previous_total_value): account_info() {
      previous_total = previous_total_value;
   }
   
   void SendReport() {
      string message = GenerateMessage();
      SendNotification(message);
   }
   
   int GetCurrentTotal() {
      return account_info.GetCurrentTotal();
   }
   
   static bool IsNotTimeToSend() {
      return !IsTimeToSend();
   }
   
   
   static int fetchInitialTotal() {
      return (int)AccountBalance();
   }
   
private:
   string GenerateMessage() {
      return "total: " + (string)account_info.GetCurrentTotal() + 
         " / diff: " + (string)(account_info.GetCurrentTotal() - previous_total) +
         " / margin: " + (string)account_info.GetFreeMargin() +
         " / ratio: " + DoubleToStr(account_info.GetMarginRatio(), 1) + "%" +
         " / orders: " + (string)account_info.GetPositionCount();
   }
   
   static bool IsTimeToSend() {
      MqlDateTime date_time;
      TimeToStruct(LocalTime(), date_time);
      int current_hour = date_time.hour;
      
      for (int i = 0; i < ArraySize(REPORT_HOURS); i++) {
         int hour = REPORT_HOURS[i];

         if (hour == current_hour) {
            return true;
         }
      }
      return false;
   }
   
};

