# OpenStudio Notebooks

Base image for using Jupyter Notebooks in OpenStudio Server.

### Dependencies

Create_OSA.ipynb requires Analysis-gem Version > 1.3.0.  To install the pre-release
git clone the 
[Analysis-gem][https://github.com/NREL/OpenStudio-analysis-gem/tree/osw_to_osa] osw_to_osa branch

In a terminal run:  
>gem build  
>gem install --local .\openstudio-analysis-1.3.0.pre.0.gem  

#### install Measure Gems
>gem install openstudio-calibration
>gem install openstudio-common-measures
