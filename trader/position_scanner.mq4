#include "../base.mqh"


class PositionScanner {

public:
   static bool ExistsPosition(int identifier) {
      PositionList position_list;
      return position_list.Contains(identifier);
   }
   
   static bool ReachedMaxPosition() {
      return GetPositionCount() >= MAX_POSITION;
   }
   
   static int GetPositionCount() {
      PositionList position_list;
      return position_list.GetSize();
   }
   

};