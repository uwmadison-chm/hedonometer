class SetScriptNameFromApache
  # Copies the HTTP_SCRIPT_NAME variable into SCRIPT_NAME

  def initialize(app)
    @app = app
  end

  def call(env)
    env['SCRIPT_NAME'] = env['HTTP_SCRIPT_NAME']
    @app.call(env)
  end
end
