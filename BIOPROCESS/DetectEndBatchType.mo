within BIOPROCESS;
block DetectEndBatchType
  LiquidCon probe;
  
  // Time units are in seconds other wise unit checking would fail 
  // Please change the parameter values accordingly 
  
  parameter Units.Concentration S_min = 1.0 "Substrate conc limitation def end of batch";
  parameter Units.Time time_final_max = 6.0 "Specification of maximal time_final value";
  parameter Units.Concentration X_final_min = 5.0 "Specification of minimal X_final value";
  discrete Units.Time time_final(start = 0, fixed = true) "Time final, when substrate conc goes below S_min";
  
  discrete Units.Concentration X_final(start = 0, fixed = true) "Cell conc final";
  discrete Units.Concentration S_final(start = 0, fixed = true) "Substrate conc final";
  discrete Units.Concentration P_final(start = 0, fixed = true) "Product conc final";
 
  // It would be better to define an enumeration type for the variable batch_evaluation 
  discrete Integer batch_evaluation(start = 0, fixed = true) "Batch evaluation - accepted for >0";
  
  // The following is not needed
  // discrete Boolean firstTime(start = true, fixed = true) "Detect crossing S<S_min firstTime only";

equation

  // the second condition after and is not needed. The event is triggered only once 
  // when probe.S < S_min and pre(firstTime) then  
  when probe.S < S_min then 
    // firstTime = false;
    time_final = time;
    X_final = probe.X;
    S_final = probe.S;
    P_final = probe.P;
    batch_evaluation = if time < time_final_max and probe.X > X_final_min then 1 elseif time > time_final_max and probe.X > X_final_min then -1
     elseif time < time_final_max and probe.X < X_final_min then -2 else -3;
  end when;
end DetectEndBatchType;
