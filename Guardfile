if RbConfig::CONFIG['host_os'] =~ /linux/
  notification :notifysend
end

guard 'rspec', 
  version: 2,
  cli: '--format documentation',
  all_on_start: false,
  all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end
