within BIOPROCESS;
block DetectEndBatchType
  LiquidCon probe;
  parameter Real S_min(unit = "g/L") = 1.0 "Substrate conc limitation def end of batch";
  parameter Real time_final_max(unit = "h") = 6.0 "Specification of maximal time_final value";
  parameter Real X_final_min(unit = "g/L") = 5.0 "Specification of minimal X_final value";
  Real time_final(start = 0, fixed = true, unit = "h") "Time final, when substrate conc goes below S_min";
  Real X_final(start = 0, fixed = true, unit = "g/L") "Cell conc final";
  Real S_final(start = 0, fixed = true, unit = "g/L") "Substrate conc final";
  Real P_final(start = 0, fixed = true, unit = "g/L") "Product conc final";
  Real batch_evaluation(start = 0, fixed = true) "Batch evaluation - accepted for >0";
  discrete Boolean firstTime(start = true, fixed = true) "Detect crossing S<S_min firstTime only";
equation
  when probe.S < S_min and pre(firstTime) then
    firstTime = false;
    time_final = time;
    X_final = probe.X;
    S_final = probe.S;
    P_final = probe.P;
    batch_evaluation = if time < time_final_max and probe.X > X_final_min then 1 elseif time > time_final_max and probe.X > X_final_min then -1
     elseif time < time_final_max and probe.X < X_final_min then -2 else -3;
  end when;
end DetectEndBatchType;
