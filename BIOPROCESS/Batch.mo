within BIOPROCESS;
model Batch
  ReactorType bioreactor;
  DetectEndBatchType monitor;
equation
  connect(bioreactor.port, monitor.probe);
end Batch;
