package BIOPROCESS
  //within BIOPROCESS;


  // Package for simulation of microbial cultivations - br1.mo
  // Here a simplified structure is used for simulation of a batch reactor,
  // but the structure can naturally be expanded to include in- and out-flows
  // to cover fedbatch, chemostat and cell re-cycle configurations.
  // Author: Jan Peter Axelsson
  // 2013-08-16 - Created
  // 2013-08-31 - Modified
  // 2018-12-20 - Added block to detect end of cultivation
  // 2018-12-21 - Added units and descriptions of variables in standard non-SI way
  // 2019-01-02 - Modified DetectecEndBatchType to detect once only and include batch evaluation
  import Modelica.Blocks.Noise.NormalNoise;

  annotation (
    uses(Modelica(version = "3.2.2")));
end BIOPROCESS;
