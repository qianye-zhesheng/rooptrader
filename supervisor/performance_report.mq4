#include "../base.mqh"

#include "account_info.mq4"
#include "report_schedule.mq4"


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
      ReportSchedule report_schedule();
      return report_schedule.IsScheduledTime();
   }
   
};

