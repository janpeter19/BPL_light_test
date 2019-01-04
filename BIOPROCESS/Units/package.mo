within BIOPROCESS;
package Units "Physical units"
  extends Modelica.Icons.TypesPackage;
  //
  // Rate units has to be expressed in terms of [s]. Parameter values need to be changed accordingly.
  // Dymola needs small letter for physical units (no idea if this is Modelica standard)
  //
  
  type Concentration = Modelica.Icons.TypeReal(final quantity = "Concentration", final unit = "g/l", min = 0) " Concentration of a substance [g/l]";

  type Volume = Modelica.Icons.TypeReal(final quantity = "Volume", final unit = "l", min = 0) "Volume [l]";

  type Mass = Modelica.Icons.TypeReal(final quantity = "Mass", final unit = "g", min = 0) "Mass [g]";

  type UptakeRate = Modelica.Icons.TypeReal(final quantity = "Uptake Rate", final unit = "1/s") "Uptake Rate [1/s]";

  type FormationRate = Modelica.Icons.TypeReal(final quantity = "Formation Rate.", final unit = "1/s") "Formation Rate [1/s]";

  type FormationRate_GrowthDep = Modelica.Icons.TypeReal(final quantity = "Formation Rate Growth Dep.", final unit = "1") "Formation Rate Growth Depedent [1]";

  type GrowthRate = Modelica.Icons.TypeReal(final quantity = "Growth Rate.", final unit = "1/s") "Growth Rate [1/s]";

  type Yield = Modelica.Icons.TypeReal(final quantity = "Yield", final unit = "1") "Yield [1]";

  type Hour = Modelica.Icons.TypeReal(final quantity = "Hour", final unit = "h") "Hour [h]";
  
  type Time = Modelica.Icons.TypeReal(final quantity = "Time", final unit = "s") "Seconds [s]"; 
end Units;
