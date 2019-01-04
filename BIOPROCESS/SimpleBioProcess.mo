within BIOPROCESS;
model SimpleBioProcess
  import BIOPROCESS.Units.*;
  // Parameters:
  parameter Concentration Ks = 0.1 "Substrate uptake saturation";
  parameter UptakeRate qSmax = 1.00  "Substrate uptake maximal rate";
  parameter Yield Yxs = 0.50 "Yield of cells from substrate";
  // parameter Real  Ypx     = 0.08 "Product formation rate growth related";
  parameter FormationRate_GrowthDep alpha = 0.08 "Product formation rate growth dependent";
  parameter FormationRate beta = 0.03  "Product formation rate not growth dependent";
  // The inital state values:
  parameter Mass VS_0 = 2;
  parameter Mass VX_0 = 1;
  parameter Mass VP_0 = 0;
  parameter Volume V_0 = 1;
  // The state variables:
  Mass VS(start = VS_0, fixed = true, min = 0.0);
  Mass VX(start = VX_0, fixed = true);
  Mass VP(start = VP_0, fixed = true);
  Volume V(start = V_0, fixed = true);
  // Concentrations and rates:
  Concentration S, X, P;
  UptakeRate qS;
  GrowthRate mu;
  FormationRate qP;
equation
  // Concentrations:
  S = VS / V;
  X = VX / V;
  P = VP / V;
  // Mass-balance for the liquid phase of the reactor:
  der(VS) = -qS * VX;
  der(VX) = mu * VX;
  der(VP) = qP * VX;
  der(V) = 0;
  // Reaction rates:
  qS = S / (S + Ks) * qSmax " Glucose uptate - Monod equation";
  mu = Yxs * qS " Growth on glucose";
  //  qP = Ypx * Yxs * qS + beta;
  qP = alpha * mu + beta "Product formation - Luedeking-Piret equation";
end SimpleBioProcess;
