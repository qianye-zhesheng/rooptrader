#include "../base.mqh"

class ReportSchedule {

private:

   static const int REPORT_HOURS[];
   static const int REPORT_MINUTE;
   
   int current_day_of_week;
   int current_hour;
   int current_minute;

public:
   ReportSchedule() {
      MqlDateTime date_time;
      TimeToStruct(LocalTime(), date_time);
      current_day_of_week = date_time.day_of_week;
      current_hour = date_time.hour;
      current_minute = date_time.min;
   }
   
   bool IsScheduledTime() {
   
      if (IsNotReportMinute()) {
         return false;
      }
      
      return IsReportHour();
   }


private:

   bool IsNotReportMinute() {
      return current_minute != REPORT_MINUTE;
   }
   
   bool IsReportHour() {
      for (int i = 0; i < ArraySize(REPORT_HOURS); i++) {
         int hour = REPORT_HOURS[i];

         if (hour == current_hour) {
            return true;
         }
      }
      return false;
   }
   
};


const int ReportSchedule::REPORT_HOURS[] = {7, 12, 17, 21};
const int ReportSchedule::REPORT_MINUTE = 5;
