#include "../base.mqh"



bool IsStepOutOfRange(double step_val) {
   return Normalize(step_val) <= 0;
}

bool IsPrefixOutOfRange(int prefix) {
   return prefix < 1 || prefix > 99;
}

void DisplayParameters() {
   string parameters = "STEP: " + DoubleToStr(STEP, Digits())  + "\n" +
      "STOP_LOSS_STEP: " + DoubleToStr(STOP_LOSS_STEP, Digits()) + "\n" +
      "ORDER_IDENTIFIER_PREFIX: " + (string)ORDER_IDENTIFIER_PREFIX;
   Comment(parameters);
}