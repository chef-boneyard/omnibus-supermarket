def disable_runit_service(service)
  ChefSpec::Matchers::ResourceMatcher.new(:runit_service, :disable, service)
end
