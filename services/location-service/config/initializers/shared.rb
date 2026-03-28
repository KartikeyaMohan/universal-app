shared_path = Pathname.new("/shared")

Dir[shared_path.join("**/*.rb")].each do |file|
  require file
end