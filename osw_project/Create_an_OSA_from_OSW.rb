
gem 'openstudio-analysis', '1.2.1.pre.7'
require 'openstudio-analysis'

OpenStudio::Analysis::VERSION


path_to_this_file = File.dirname(File.expand_path(__FILE__))
path_to_file_from_here = "calibration_workflow.osw"
full_path_to_file = File.expand_path(path_to_file_from_here, path_to_this_file)

osw_filename = full_path_to_file
puts osw_filename
#load OSW
if File.exist? osw_filename
  puts "found file"
else
  puts "file not found at: #{osw_filename}"  
end

analysis = OpenStudio::Analysis.create('Analysis Name')

a = analysis.convert_osw(osw_filename)

o = analysis.add_output(
      display_name: 'electricity_consumption_cvrmse',
      name: 'calibration_reports_enhanced.electricity_consumption_cvrmse',
      units: '%',
      objective_function: true
    )

o = analysis.add_output(
      display_name: 'electricity_consumption_nmbe',
      name: 'calibration_reports_enhanced.electricity_consumption_nmbe',
      units: '%',
      objective_function: true,
      objective_function_group: 2
    )

o = analysis.add_output(
      display_name: 'natural_gas_consumption_cvrmse',
      name: 'calibration_reports_enhanced.natural_gas_consumption_cvrmse',
      units: '%',
      objective_function: true,
    objective_function_group: 3
    )

o = analysis.add_output(
      display_name: 'natural_gas_consumption_nmbe',
      name: 'calibration_reports_enhanced.natural_gas_consumption_nmbe',
      units: '%',
      objective_function: true,
      objective_function_group: 4
    )

o = analysis.add_output(
      display_name: 'electricity_ip',
      name: 'openstudio_results.electricity_ip',
      units: '%',
    )

#change paths to jsons to work on the server
m = analysis.workflow.find_measure('add_monthly_json_utility_data')
m.argument_value('json','../../../lib/calibration_data/electric.json')
m = analysis.workflow.find_measure('add_monthly_json_utility_data_2')
m.argument_value('json','../../../lib/calibration_data/natural_gas.json')

m = analysis.workflow.find_measure('general_calibration_measure_percent_change')
d = {
      type: 'uniform',
      minimum: -50,
      maximum: 50,
      mean: 0
    }
m.make_variable('lights_perc_change', 'Lights Percent Change', d)

m = analysis.workflow.find_measure('general_calibration_measure_percent_change')
d = {
      type: 'uniform',
      minimum: -50,
      maximum: 50,
      mean: 0
    }
m.make_variable('ElectricEquipment_perc_change', 'Electric Equipment Percent Change', d)

#add data_point initialization script
full_path_to_file = File.expand_path("scripts/script.sh", path_to_this_file)
analysis.server_scripts.add(full_path_to_file, ['one', 'two'])
# add analysis finalization script
analysis.server_scripts.add(full_path_to_file, ['three', 'four'], 'finalization', 'analysis')   
    
#save file relative to this file
File.write('analysis.json',JSON.pretty_generate(analysis.to_hash))

#default analysis is single_run, change to NSGA2
analysis.analysis_type = 'nsga_nrel'

#The add_monthly_json_utility_data needs the external data.
#To upload it, give the path to the directory, in this case Data
#It will be call 'calibration_data' and live at /lib/calibration_data in the server
#use relative path from this file to Data directory 
full_path_to_file = File.expand_path("Data", path_to_this_file)
analysis.libraries.add(full_path_to_file, {library_name: 'calibration_data'})

#save file relative to this file
analysis.save_osa_zip('analysis.zip')




