service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action :nothing # only define so that it can be restarted if the config changed
end

require 'aws-sdk'

s3 = AWS::S3.new

# Set bucket and object name
obj = s3.buckets['j6-haproxy-test'].objects['projects.json']

# Read content to variable
file_content = obj.read

# Log output (optional)
Chef::Log.info(file_content)

instances = "instances": JSON.parse(file_content)

template "/etc/haproxy/haproxy.cfg" do
  cookbook "haproxy"
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, "service[haproxy]"
  variables :instances => instances
end

execute "echo 'checking if HAProxy is not running - if so start it'" do
  not_if "pgrep haproxy"
  notifies :start, "service[haproxy]"
end

