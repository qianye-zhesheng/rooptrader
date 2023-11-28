#include "../base.mqh"


class NotifiedDateTime {


private:
   int year;
   int month;
   int day;
   int hour;
   
   NotifiedDateTime(const int year_val, const int month_val, const int day_val, const int hour_val) {
      year = year_val;
      month = month_val;
      day = day_val;
      hour = hour_val;
   }


public:

   NotifiedDateTime(NotifiedDateTime& notified_datetime) {
      year = notified_datetime.GetYear();
      month = notified_datetime.GetMonth();
      day = notified_datetime.GetDay();
      hour = notified_datetime.GetHour();
   }
   
   static NotifiedDateTime OfCurrent() {
      MqlDateTime date_time;
      TimeToStruct(LocalTime(), date_time);
      NotifiedDateTime notified_date_time(date_time.year, date_time.mon, date_time.day, date_time.hour);
      return notified_date_time;
   }
   
   static NotifiedDateTime OfEmpty() {
      NotifiedDateTime notified_date_time(0, 0, 0, 0);
      return notified_date_time;
   }
   
   bool IsEqualTo(NotifiedDateTime& notification_datetime) {
      return year == notification_datetime.GetYear()
         && month == notification_datetime.GetMonth()
         && day == notification_datetime.GetDay()
         && hour == notification_datetime.GetHour();
   }
   
   int GetYear() {
      return year;
   }
   
   int GetMonth() {
      return month;
   }
   
   int GetDay() {
      return day;
   }
   
   int GetHour() {
      return hour;
   }

   
};