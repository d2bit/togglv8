require_relative 'toggl_conn'

class TogglReports
  include TogglConn

  def weekly(workspace, params = {})
    get_reports :weekly, params.merge(workspace_id: workspace)
  end

  def details(workspace, params = {})
    get_reports :details, params.merge(workspace_id: workspace)
  end

  def details_without_pagination(workspace, params = {})
    page = 0
    result = []

    begin
      page += 1
      response = details workspace, params.merge(page: page)
      result += response
    end until response.size < 50

    result
  end

  def summary(workspace, params = {})
    get_reports :summary, params.merge(workspace_id: workspace)
  end

  private

  def get_reports(type, hash_params)
    get "#{ type.to_s }?#{ hash_to_params_query(hash_params) }"
  end

  def hash_to_params_query(hash_params)
    hash_params.map do |k, v|
      v = v.map(&:to_s).join(',') if v.is_a? Array
      "#{ k.to_s }=#{ v.to_s }"
    end.join('&')
  end
end
