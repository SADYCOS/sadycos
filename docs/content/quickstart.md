---
title: Quickstart
layout: page
nav_order: 2
---

# Quickstart
{: .no_toc }
This guide will help you set up SADYCOS on your machine, run a simple simulation and inspect the simulation results.

## Page Contents
{: .no_toc .text-delta }
- TOC
{:toc}

## Prerequisites
To effectively work with SADYCOS, you need the following software installed on your machine:
- Git
- MATLAB R2024b or newer with
    - Simulink
    - a supported compiler for the inclusion of external c code
        - e.g. [MinGW](https://de.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-mingw-w64-c-c-fortran-compiler) on Windows machines
        - see [MATLAB and Simulink Requirements](https://de.mathworks.com/support/requirements/supported-compilers.html) for more information
    - (not needed for this tutorial) further toolboxes for some models or extended functionality:
        - Aerospace Toolbox
        - Mapping Toolbox
        - Parallel Computing Toolbox

Older versions of MATLAB might work, but are not tested.

## Installation
First, you need to clone the [Github Repository](https://github.com/SADYCOS/sadycos).
Since the repository uses submodules, you cannot simply download the files as a zip archive but need to properly clone it.
If you plan on synchronizing your clone of SADYCOS with Github, you should first [fork the repository](https://github.com/SADYCOS/sadycos/fork) and then clone your own fork to your machine.
Otherwise you can clone the repository directly with the following command:
```bash
git clone https://github.com/SADYCOS/sadycos.git --recurse-submodules
```

## Running a Simulation
1. Navigate to the cloned repository and open MATLAB.
    ```bash
    cd sadycos
    matlab .
    ```
2. Within MATLAB, open the MATLAB project _SADYCOS_. Either double click on the file `SADYCOS.prj` in the current folder view or enter the following command in the MATLAB command window:
    ```matlab
    openProject("SADYCOS.prj");
    ```
    This will ensure that the MATLAB path is set up correctly and that all necessary files are available to MATLAB.
3. Simulations are configured as classes within the directory `UserFiles/Configurations`.
Initially you will find a namespace `ExampleMission` containing two configuration classes:
    1. `DefaultConfiguration`
    2. `GainSearch`

    Running the default configuration is as simple as creating an object of the class and calling the run method in MATLAB's command window:
    ```matlab
    o = ExampleMission.DefaultConfiguration;
    o.run;
    ```
    SADYCOS will display the progress of the individual steps of preparing the simulation model (configuring parameters, buses and simulation inputs and generating interface files) before running the simulation in the background.
    Afterwards, an output to the command line will indicate that the simulation has finished.

## Inspecting the Results
The simulation results are stored as a `Simulink.SimulationOutput` object inside the configuration object.
You can go ahead and explore the data by accessing the corresponding property:
```matlab
o.simulation_outputs
```
For example, you can plot the time series of the satellite's angular velocity vector's three elements simply by executing the following commands:
```matlab
figure;
plot(o.simulation_outputs.logsout{3}.Values.PlantOutputs.RigidBody.angular_velocity_BI_B__rad_per_s);
```