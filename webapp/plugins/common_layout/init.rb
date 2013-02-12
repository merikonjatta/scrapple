class Compund::Plugins::CommonLayout

  def self.use_common_layout(app, locals)
    app.erb(:"plugins/common_layout/main", :locals => locals)
  end

end
