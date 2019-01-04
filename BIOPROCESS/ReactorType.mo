within BIOPROCESS;
model ReactorType
  LiquidCon port;
  // Parameters:
  parameter Real Ks(unit = "g/L") = 0.1 "Substrate uptake saturation";
  parameter Real qSmax(unit = "g/(g*h)") = 0.5 "Substrate uptake maximal rate";
  parameter Real Yxs(unit = "g/g") = 0.50 "Yield of cells from substrate";
  parameter Real alpha(unit = "g/g") = 0.08 "Product formation rate growth related";
  parameter Real beta(unit = "g/(g*h)") = 0.03 "Product formation rate not growth related";
  // The inital state values:
  parameter Real VS_0(unit = "g") = 10.0 "Initial substrate mass";
  parameter Real VX_0(unit = "g") = 2.0 "Initial cell mass";
  parameter Real VP_0(unit = "g") = 0.0 "Initial product mass";
  parameter Real V_0(unit = "L") = 1.0 "Initial volume reactor broth";
  // The state variables:
  Real VS(start = VS_0, fixed = true, unit = "g") "Substrate conc";
  Real VX(start = VX_0, fixed = true, unit = "g") "Cell mass";
  Real VP(start = VP_0, fixed = true, unit = "g") "Product mass";
  Real V(start = V_0, fixed = true, unit = "L") "Volume reactor broth";
  // Concentrations and rates:
  Real S(unit = "g/L") "Substrate conc";
  Real X(unit = "g/L") "Cell conc";
  Real P(unit = "g/L") "Product conc";
  Real qS(unit = "g/(g*h)") "Specific substrate uptake rate";
  Real qP(unit = "g/(g*h)") "Specific product formation rate";
  Real mu(unit = "1/h") "Specific cell growth rate";
equation
  // Concentrations:
  S = VS / V;
  X = VX / V;
  P = VP / V;
  port.S = S;
  port.X = X;
  port.P = P;
  // Mass-balance for the liquid phase of the reactor:
  der(VS) = -qS * VX;
  der(VX) = mu * VX;
  der(VP) = qP * VX;
  der(V) = 0;
  // Reaction rates:
  qS = S / (S + Ks) * qSmax;
  // Substrate uptate - Monod equation
  mu = Yxs * qS;
  // Growth on substrate
  qP = alpha * mu + beta;
  // Product formation - Luedeking-Piret equation
end ReactorType;
