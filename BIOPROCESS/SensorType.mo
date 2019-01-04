within BIOPROCESS;
block SensorType
  input LiquidCon probe;
  discrete output LiquidCon out;
  parameter Real sigma(unit = "g/L") = 0.1 "Standard deviation on measured substrate conc S";
  parameter Units.Time samplePeriod = 0.1 "Sample period of noise generator";
  parameter Units.Time sampleStart = samplePeriod "Start time";
  NormalNoise noise(samplePeriod = samplePeriod, mu = 0.0, sigma = sigma);
  inner Modelica.Blocks.Noise.GlobalSeed globalSeed;
equation
  when sample(sampleStart, samplePeriod) then
    out.X = probe.X;
    out.S = probe.S + noise.y;
    out.P = probe.P;
  end when;
end SensorType;
