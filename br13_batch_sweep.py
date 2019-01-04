# Figure - Simulation of batch reactor.
#
# Author: Jan Peter Axelsson
# 2012-12-20 - Created
# 2018-12-20 - Tested for JModelica 2.4 and found OK
# 2018-12-21 - Parameter sweep
# 2018-12-23 - Added constraint on X_final
# 2018-12-23 - Added noise
# 2018-12-28 - General resolution nY, nqSmax introduced
# 2019-01-02 - Modified for br13 and batch evaluation in Modelica instead
#----------------------------------------------------------------------------------

# Setup of Modelica etc
import numpy as np 
import matplotlib.pyplot as plt 
from pymodelica import compile_fmu 
from pyfmi import load_fmu
from pyfmi.fmi import FMUException

# Define model file name and class name 
model_name = 'BIOPROCESS.Batch' 
model_file = 'br13.mo'

# Compile model
fmu_model = compile_fmu(model_name, model_file)

# Load model
model = load_fmu(fmu_model)

# Utility function
def describe(name):
     """Look up description and unit of parameters and variables in the model code"""
     description = model.get_variable_description(name)
     try:
         unit = model.get_variable_unit(name)
     except FMUException:
         unit =''
     if unit =='':
         print description
     else:
         print description,'[',unit,']'

# Simulation time
simulationTime = 8.0

# Create parDict
parDict = {}
parDict['bioreactor.V_0'] = 1.0
parDict['bioreactor.VS_0'] = 10.0
parDict['bioreactor.VX_0'] = 2.0
parDict['bioreactor.VP_0'] = 0.0

parDict['bioreactor.Yxs'] = 0.5
parDict['bioreactor.qSmax'] = 0.5
parDict['bioreactor.Ks'] = 0.1
parDict['bioreactor.alpha'] = 0.08
parDict['bioreactor.beta'] = 0.03

parDict['monitor.S_min'] = 1.0
parDict['monitor.time_final_max'] = 6.0
parDict['monitor.X_final_min'] = 5.0

# Setup plot window
plt.figure()
plt.clf()

plt.subplot(3,1,1)
plt.title('Batch cultivation')
plt.grid()
plt.ylabel('X [g/L]')

plt.subplot(3,1,2)
plt.grid()
plt.ylabel('S [g/L]')

plt.subplot(3,1,3)
plt.grid()
plt.ylabel('mu [1/h]')
plt.xlabel('Time [h]')

plt.show()

# Sweep ranges and storage of final data:
nY = 20
nqSmax = 20
Yxs_range = np.linspace(0.3,0.5,nY)
qSmax_range = np.linspace(0.4,0.6,nqSmax)

data = np.zeros([nY,nqSmax,5])


# Do the parameter sweep and all simulations

for j in range(nY):
    for k in range(nqSmax):
        
        model = load_fmu(fmu_model)
        
        for key in parDict.keys(): model.set(key,parDict[key]) 
        
        model.set('bioreactor.Yxs', Yxs_range[j])
        model.set('bioreactor.qSmax', qSmax_range[k])
    
        # Simulate
        sim_res = model.simulate(final_time=simulationTime)

        # Get simulation result
        res = sim_res.result_data
        X = res.get_variable_data('bioreactor.X')
        S = res.get_variable_data('bioreactor.S')
        mu = res.get_variable_data('bioreactor.mu')
        
        time_final = res.get_variable_data('monitor.time_final').x[-1]
        X_final = res.get_variable_data('monitor.X_final').x[-1]
        S_final = res.get_variable_data('monitor.S_final').x[-1]
        batch_evaluation = res.get_variable_data('monitor.batch_evaluation')
        
        # Store final results
        data[j,k,0] = Yxs_range[j]
        data[j,k,1] = qSmax_range[k]
        data[j,k,2] = time_final
        data[j,k,3] = X_final
        data[j,k,4] = batch_evaluation.x[-1]

        # Plot simulation results        
        plt.subplot(3,1,1)    
        if batch_evaluation.x[-1]>0:
            plt.plot(X.t,X.x,'b-')
        else:
            plt.plot(X.t,X.x,'r-')   
        plt.subplot(3,1,2)
        if batch_evaluation.x[-1]>0:
            plt.plot(S.t,S.x,'b-')
        else:
            plt.plot(S.t,S.x,'r-')           
           
        plt.subplot(3,1,3)
        if batch_evaluation.x[-1]>0:
            plt.plot(mu.t,mu.x,'b-')
        else:
            plt.plot(mu.t,mu.x,'r-')           

plt.figure()
plt.subplot(1,2,1)
for j in range(nY):
    for k in range(nqSmax):
        if data[j,k,4] > 0: 
            plt.scatter(data[j,k,0],data[j,k,1],c='b')
        else:
            plt.scatter(data[j,k,0],data[j,k,1],c='r')           
plt.grid()
#plt.axis([0, 0.8, 0, 0.8])
plt.ylabel('qSmax [g/g,h]')
plt.xlabel('Yxs [g/g]')
plt.title('Process parameter space')
        
plt.subplot(1,2,2)
for j in range(nY):
    for k in range(nqSmax):
        if data[j,k,4] > 0:         
            plt.scatter(data[j,k,2],data[j,k,3],c='b')
        else:
            plt.scatter(data[j,k,2],data[j,k,3],c='r')                 
plt.grid()
#plt.axis([0, 8, 0, 8])
plt.xlabel('T_final [h]')
plt.ylabel('X_final [g/L]')
plt.title('Batch evaluation space')
        
plt.show()       