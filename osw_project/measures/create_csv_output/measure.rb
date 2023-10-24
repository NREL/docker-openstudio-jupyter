# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'erb'
require 'time'  # Add this line to use the Time class for timestamp formatting

# start the measure
class CreateCSVOutput < OpenStudio::Measure::ReportingMeasure
  # human readable name
  def name
    return 'CreateCSVOutput'
  end

  # human readable description
  def description
    return 'Create CSV output for output variables in SQL file'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Create CSV output for output variables in SQL file'
  end

  # define the arguments that the user will input
  def arguments(model = nil)
    args = OpenStudio::Measure::OSArgumentVector.new
    reporting_frequency_chs = OpenStudio::StringVector.new
    reporting_frequency_chs << "Hourly"
    reporting_frequency_chs << "Zone Timestep"
    reporting_frequency_chs << "HVAC System Timestep"
    reporting_frequency_chs << "All"
    reporting_frequency = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('reporting_frequency', reporting_frequency_chs, true)
    reporting_frequency.setDisplayName("Reporting Frequency.")
    reporting_frequency.setDefaultValue("Hourly")
    args << reporting_frequency 

    return args
  end

  # define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    if !runner.validateUserArguments(arguments(), user_arguments)
      return false
    end
	
    reporting_frequency = runner.getStringArgumentValue("reporting_frequency",user_arguments) 
	
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError("Cannot find last model.")
      return false
    end
    model = model.get

    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError("Cannot find last sql file.")
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)
	
    ann_env_pd = nil
    sqlFile.availableEnvPeriods.each do |env_pd|
      env_type = sqlFile.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new("WeatherRunPeriod")
          ann_env_pd = env_pd
          break
        end
      end
    end
		
		unless reporting_frequency == "All"
			headers = ["timestamp"]
			output_timeseries = {}
		
			variable_names = sqlFile.availableVariableNames(ann_env_pd, reporting_frequency)
			variable_names.each do |variable_name|
				key_values = sqlFile.availableKeyValues(ann_env_pd, reporting_frequency, variable_name.to_s)
				if key_values.size == 0
					 runner.registerError("Timeseries for #{variable_name} did not have any key values. No timeseries available.")
				end
				
				key_values.each do |key_value|
					timeseries = sqlFile.timeSeries(ann_env_pd, reporting_frequency, variable_name.to_s, key_value.to_s)
					if !timeseries.empty?
						timeseries = timeseries.get
						units = timeseries.units
                        if key_value.empty?
						  headers << "#{variable_name.to_s}[#{units}]"
                        else
                          headers << "#{key_value.to_s}:#{variable_name.to_s}[#{units}]"                          
                        end
						output_timeseries[headers[-1]] = timeseries
					else 
						runner.registerWarning("Timeseries for #{key_value} #{variable_name} is empty.")
					end	  
				end
			end	
				
			if output_timeseries.empty?
				puts "No output variables found at reporting frequency = #{reporting_frequency}"
			else
				
				csv_array = []
				csv_array << headers
				
				date_times = output_timeseries[output_timeseries.keys[0]].dateTimes
				
				values = {}
				for key in output_timeseries.keys
					values[key] = output_timeseries[key].values
				end
				
				num_times = date_times.size - 1
				for i in 0..num_times
					date_time = date_times[i]

					# Parse and reformat the timestamp.
					parsed_time = Time.parse(date_time.to_s)
					formatted_time = parsed_time.strftime('%-m/%-d/%Y %H:%M:%S')

					row = []
					row << formatted_time
					for key in headers[1..-1]
						value = values[key][i]
						row << value
					end
					csv_array << row
				end

				File.open("./report_variables_#{reporting_frequency.delete(' ')}.csv", 'wb') do |file|
					csv_array.each do |elem|
						file.puts elem.join(',')
					end
				end
				
				runner.registerInfo("Output file written to #{Dir.pwd}/report_variables_#{reporting_frequency.delete(' ')}.csv")
			end
		end
		
		return true
  end
end

# register the measure to be used by the application
CreateCSVOutput.new.registerWithApplication
