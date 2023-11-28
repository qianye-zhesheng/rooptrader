#include "../base.mqh"

#include "notified_date_time.mq4"

class OrderLimitationNotifier {

private:
   NotifiedDateTime last_notified_time;
   
   static const string MESSAGE;


public:
   
   OrderLimitationNotifier(NotifiedDateTime& last_notified_time_val):
      last_notified_time(last_notified_time_val) {}
   
   void Notify() {
      if (IsNotTimeToNotify()) {
         return;
      }
      
      Print(MESSAGE);
      SendNotification(MESSAGE);
      
      last_notified_time = NotifiedDateTime::OfCurrent();
   }
   
   NotifiedDateTime GetLastNotifiedTime() {
      return last_notified_time;
   }
   
   
private:   
   
   bool IsNotTimeToNotify() {
      return last_notified_time.IsEqualTo(NotifiedDateTime::OfCurrent());
   }

};

const string OrderLimitationNotifier::MESSAGE = "Order was not sent due to limitation";