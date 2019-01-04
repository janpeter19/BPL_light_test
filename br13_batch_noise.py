# Figure - Simulation of batch reactor.
#
# Author: Jan Peter Axelsson
# 2012-10-16 - Created
# 2012-10-25 - Modified 
# 2013-08-31 - Modified 
# 2016-09-15 - Modified
# 2018-01-29 - Tested with JModelica version: 2.1 and OK
# 2018-02-08 - Adjusted graph to be similar to parameter sweep diagrams
# 2018-12-20 - Tested for JModelica 2.4 and found OK
# 2018-12-27 - Checking that noise added on S looks reasonable 
# 2019-01-02 - Added print of actual seed to both diagram and terminal
#----------------------------------------------------------------------------------

# Setup of Modelica etc
import numpy as np 
import matplotlib.pyplot as plt 
from pymodelica import compile_fmu 
from pyfmi import load_fmu

# Define model file name and class name 
model_name = 'BIOPROCESS.BatchWithNoise' 
model_file = 'br13.mo'

# Compile model
fmu_model = compile_fmu(model_name, model_file)

# Load model
model = load_fmu(fmu_model)

# Simulation time 
simulationTime = 7.0

# Specification of acceptable batch
t_final_max = 6.0    # h
X_final_min = 5.0    # g/L

# Initial values - changes from the model default values
model.set('bioreactor.V_0',1.0)
model.set('bioreactor.VX_0',2.0)
model.set('bioreactor.VS_0',10.0)
model.set('bioreactor.VP_0',0.0)

# Parameters
model.set('bioreactor.qSmax',0.5)  # Stabdard 0.50 
model.set('bioreactor.Ks',0.1)    
model.set('bioreactor.Yxs',0.5)    # Standard 0.50
model.set('bioreactor.alpha',0.08)
model.set('bioreactor.beta',0.03)

model.set('sensor.sigma',0.48)   # 0.48 - ok but for 0.60 detection does not work
model.set('monitor.S_min',1.0)   

# Parameters for the noise generator
seed = 1  # In JModelica seed=1 gives wrong detection point
model.set('sensor.noise.useGlobalSeed', False)
model.set('sensor.noise.useAutomaticLocalSeed', False)
model.set('sensor.noise.fixedLocalSeed', seed)

# Simulate
sim_res = model.simulate(final_time=simulationTime)

# Get simulation result
res = sim_res.result_data
X = res.get_variable_data('bioreactor.X')
S = res.get_variable_data('bioreactor.S')
P = res.get_variable_data('bioreactor.P')
mu = res.get_variable_data('bioreactor.mu')
Sn = res.get_variable_data('sensor.out.S')

time_final = res.get_variable_data('monitor.time_final').x[-1]
X_final = res.get_variable_data('monitor.X_final').x[-1]
S_final = res.get_variable_data('monitor.S_final').x[-1]
batch_evaluation = res.get_variable_data('monitor.batch_evaluation')

print '----------------------------------------'
print 'Seed for random noise generator =', seed
print 'time_final =', time_final
print 'X_final =', X_final

if batch_evaluation.x[-1] > 0: 
    print 'Batch accepted'
else: print 'Batch failure'

# Plot simulation results
plt.figure()
plt.clf()

plt.subplot(4,1,1)
plt.title('Batch reactor - noise on S / seed = ' + str(seed))
plt.plot(X.t,X.x,'r')
plt.plot(S.t,S.x,'b')
plt.plot(time_final*np.array([1,1]),np.array([0, 8]),'k:')
plt.plot(time_final, X_final,'ro')
plt.plot(time_final, S_final,'bo')
plt.grid()
plt.legend(['X','S'])
plt.ylabel('X and S [g/L]')

plt.subplot(4,1,2)
S_min = model.get('monitor.S_min')
plt.plot(S.t,S.x)
plt.step(Sn.t,Sn.x,'b',where='post')
plt.plot([0,simulationTime], [S_min, S_min],'r:')
plt.grid()
plt.ylabel('S [g/L]')   
    
plt.subplot(4,1,3)
plt.plot(mu.t,mu.x,'r')
plt.grid()
plt.ylabel('mu [1/h]')

plt.subplot(4,1,4)
plt.step(batch_evaluation.t,batch_evaluation.x,where='post', color='b')
plt.grid()
margin = 0.35
plt.axis([-margin,simulationTime + margin,-3.5,1.5])
plt.ylabel('Batch evaluation')
plt.xlabel('Time [h]')

plt.show()
