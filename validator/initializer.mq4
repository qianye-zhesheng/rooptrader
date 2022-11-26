#include "../base.mqh"



bool IsStepOutOfRange(double step_val) {
   return Normalize(step_val) <= 0;
}

bool IsPrefixOutOfRange(int prefix) {
   return prefix < 1 || prefix > 99;
}

bool IsMaxPositionOutOfRange(int max_position_val) {
   return max_position_val < 1 || max_position_val > 99;
}

bool IsRateOutOfRange(double acceptable_rate_val) {
   return Normalize(acceptable_rate_val) <= 0;
}

void DisplayParameters() {
   string parameters = "STEP: " + DoubleToStr(STEP, Digits()) + "\n" +
      "MAX_POSITION: " + (string)MAX_POSITION + "\n" +
      "MIN_ACCEPTABLE_RATE: " + DoubleToStr(MIN_ACCEPTABLE_RATE, Digits()) + "\n" +
      "MAX_ACCEPTABLE_RATE: " + DoubleToStr(MAX_ACCEPTABLE_RATE, Digits()) + "\n" +
      "ORDER_IDENTIFIER_PREFIX: " + (string)ORDER_IDENTIFIER_PREFIX;
   Comment(parameters);
}