require 'xcodeproj'
project_path = '/Users/foundation26/Downloads/New project/BudgetPlanner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

main_group = project.main_group['BudgetPlanner']

# The project might not have 'BudgetPlanner' subgroup under main_group depending on structure.
# Let's find out where the source files are.
if main_group.nil?
  # Try to find a group that contains 'ContentView.swift' or just add to main_group
  main_group = project.main_group.groups.find { |g| g.name == 'BudgetPlanner' || g.path == 'BudgetPlanner' }
  if main_group.nil?
    main_group = project.main_group.new_group('BudgetPlanner', 'BudgetPlanner')
  end
end

resources_build_phase = target.resources_build_phase

file_ref = main_group.files.find { |f| f.path == 'Assets.xcassets' }
if file_ref.nil?
  file_ref = main_group.new_file('Assets.xcassets')
  resources_build_phase.add_file_reference(file_ref)
end

target.build_configurations.each do |config|
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  # Just to ensure it compiles
  # config.build_settings['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor' # Optional
end

project.save
puts "Added Assets.xcassets and configured AppIcon to project."
