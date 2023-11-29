#include "../base.mqh"

class ReportSchedule {

private:

   static const int REPORT_HOURS[];
   static const int REPORT_MINUTE;
   static const int NOON;
   
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
      
      if (IsWeekend()) {
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
   
   bool IsWeekend() {
      return IsSaturdayAfternoon() || IsSunday();
   }
   
   bool IsSunday() {
      return current_day_of_week == SUNDAY;
   }
   
   bool IsSaturdayAfternoon() {
      if (current_day_of_week != SATURDAY) {
         return false;
      }
      
      return current_hour >= NOON;
   }
   
};


const int ReportSchedule::REPORT_HOURS[] = {7, 12, 17, 21};
const int ReportSchedule::REPORT_MINUTE = 5;
const int ReportSchedule::NOON = 12;
