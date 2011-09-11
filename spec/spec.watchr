require 'autowatchr'

Autowatchr.new(self) do |config|
  config.test_dir = 'spec'
  config.test_re = "^#{config.test_dir}/(.*)_spec\.rb$"
  config.test_file = '%s_spec.rb'
  config.require = ['config/load.rb', 'spec/spec_helper.rb']
end
