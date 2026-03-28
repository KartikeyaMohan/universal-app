module Response
  def json_response(object, http_status = :ok, log = true)
    response = { data: object, status: Rack::Utils.status_code(http_status) }
    render json: response, status: http_status
  end

  def json_error_response(errors, http_status = :unprocessable_content)
    response = { errors: errors, status: Rack::Utils.status_code(http_status) }
    render json: response, status: http_status
  end
end