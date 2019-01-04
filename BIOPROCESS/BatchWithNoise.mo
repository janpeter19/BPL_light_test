within BIOPROCESS;
model BatchWithNoise
  ReactorType bioreactor;
  SensorType sensor;
  DetectEndBatchType monitor;
equation
  connect(bioreactor.port, sensor.probe);
  connect(sensor.out, monitor.probe);
end BatchWithNoise;
