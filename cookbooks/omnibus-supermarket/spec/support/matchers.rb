def disable_runit_service(service)
  ChefSpec::Matchers::ResourceMatcher.new(:runit_service, :disable, service)
end

def create_oc_id_application(application)
  ChefSpec::Matchers::ResourceMatcher.new(:oc_id_application, :create, application)
end
