package BIOPROCESS

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
    
	connector LiquidCon
		Real S (unit="g/L")                   "Substrate conc";
		Real X (unit="g/L")                   "Cell conc";
		Real P (unit="g/L")                   "Product conc";
	end LiquidCon;
	
    model ReactorType
		LiquidCon port;
		
        // Parameters:        
        parameter Real Ks (unit="g/L") = 0.1          "Substrate uptake saturation";
        parameter Real qSmax (unit="g/(g*h)") = 0.5   "Substrate uptake maximal rate";
        parameter Real Yxs (unit="g/g") = 0.50        "Yield of cells from substrate"; 
        parameter Real alpha (unit="g/g") = 0.08      "Product formation rate growth related";
        parameter Real beta (unit="g/(g*h)")= 0.03    "Product formation rate not growth related";

        // The inital state values:
        parameter Real VS_0 (unit="g") = 10.0         "Initial substrate mass";   
        parameter Real VX_0 (unit="g") = 2.0          "Initial cell mass";
        parameter Real VP_0 (unit="g") = 0.0          "Initial product mass";   
        parameter Real V_0 (unit="L") = 1.0           "Initial volume reactor broth"; 

        // The state variables:
        Real VS(start = VS_0,fixed = true, unit="g")  "Substrate conc";
        Real VX(start = VX_0,fixed = true, unit="g")  "Cell mass";
        Real VP(start = VP_0,fixed = true, unit="g")  "Product mass";
        Real V(start = V_0,fixed = true, unit="L")    "Volume reactor broth"; 

        // Concentrations and rates:
    	Real S (unit="g/L")                           "Substrate conc";
		Real X (unit="g/L")                   "Cell conc"; 
		Real P (unit="g/L")                   "Product conc"; 
    	Real qS (unit="g/(g*h)")                      "Specific substrate uptake rate";
		Real qP (unit="g/(g*h)")              "Specific product formation rate"; 
		Real mu (unit="1/h")                  "Specific cell growth rate";
    equation
        // Concentrations:
        S = VS/V;                        
        X = VX/V;                
        P = VP/V;                 

		port.S = S;
		port.X = X;
		port.P = P;
		
        // Mass-balance for the liquid phase of the reactor:
        der(VS) = -qS*VX;
        der(VX) =  mu*VX;
        der(VP) =  qP*VX;
        der(V)  =  0;

        // Reaction rates:
        qS = S/(S+Ks)*qSmax;       // Substrate uptate - Monod equation
        mu = Yxs*qS;               // Growth on substrate 
        qP = alpha*mu + beta;      // Product formation - Luedeking-Piret equation
    end ReactorType;
	
	block DetectEndBatchType
		LiquidCon probe;
		parameter Real S_min (unit="g/L") = 1.0                 "Substrate conc limitation def end of batch";
		parameter Real time_final_max (unit="h") = 6.0          "Specification of maximal time_final value";
		parameter Real X_final_min (unit="g/L") = 5.0           "Specification of minimal X_final value";
		Real time_final (start=0, fixed=true, unit="h")         "Time final, when substrate conc goes below S_min";
		Real X_final (start=0, fixed=true, unit="g/L")          "Cell conc final";
		Real S_final (start=0, fixed=true, unit="g/L")          "Substrate conc final";
		Real P_final (start=0, fixed=true, unit="g/L")          "Product conc final" ;
		Real batch_evaluation (start=0, fixed=true)             "Batch evaluation - accepted for >0";
	    discrete Boolean firstTime (start=true, fixed=true)         "Detect crossing S<S_min firstTime only";
	equation
		when (probe.S < S_min) and pre(firstTime) then
			firstTime = false;
			time_final = time;
			X_final = probe.X;
			S_final = probe.S;
			P_final = probe.P;
			batch_evaluation = if (time < time_final_max) and (probe.X > X_final_min) then 1 
							   elseif (time > time_final_max) and (probe.X > X_final_min) then -1
							   elseif (time < time_final_max) and (probe.X < X_final_min) then -2
							   else -3;
		end when;
	end DetectEndBatchType;

 	import Modelica.Blocks.Noise.NormalNoise;

	block SensorType
		input LiquidCon probe;
		discrete output LiquidCon out;
		parameter Real sigma (unit="g/L") = 0.1                 "Standard deviation on measured substrate conc S";
		parameter Real samplePeriod (unit="h") = 0.1            "Sample period of noise generator";
		parameter Real sampleStart (unit="h") = samplePeriod    "Start time";	

		NormalNoise noise(samplePeriod=samplePeriod, mu=0.0, sigma=sigma);
			inner Modelica.Blocks.Noise.GlobalSeed globalSeed;
		
	equation
		when sample(sampleStart, samplePeriod) then
			out.X = probe.X;
			out.S = probe.S + noise.y;
			out.P = probe.P;
		end when;
	end SensorType;

    model Batch
        ReactorType bioreactor; 
		DetectEndBatchType monitor;
	equation
		connect(bioreactor.port, monitor.probe);
    end Batch;
	
	model BatchWithNoise
        ReactorType bioreactor; 
		SensorType sensor;
		DetectEndBatchType monitor;
	equation
		connect(bioreactor.port, sensor.probe);	
		connect(sensor.out, monitor.probe);
	end BatchWithNoise;

end BIOPROCESS;
