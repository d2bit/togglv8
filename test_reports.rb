require_relative 'toggl_reports'

tr = TogglReports.new
# tr.debug_on
hash = { user_agent: 'david', since: '2015-01-01' }

summary_report = tr.summary '733178', hash.merge(grouping: 'users', subgrouping: 'projects')

def show_clean_info(report_hash)
  report_hash.each do |user_info|
    puts user_info['title']['user']
    user_info['items'].each do |project_info|
      puts "  %9s  %2d" % [project_info['title']['project'], project_info['time'] * 100 / user_info['time']]
    end
    puts
  end
end

show_clean_info(summary_report)

# details_report = tr.details '733178', hash
# details_report = tr.details_without_pagination '733178', hash
# ap details_report.class
# ap details_report.size
