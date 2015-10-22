#
# Cookbook Name:: haproxy
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
package 'haproxy' do
  action :install
end

if platform?('debian','ubuntu')
  template '/etc/default/haproxy' do
    source 'haproxy-default.erb'
    owner 'root'
    group 'root'
    mode 0644
  end
end

include_recipe 'haproxy::service'

require 'aws-sdk'

s3 = AWS::S3.new
# Set bucket and object name
obj = s3.buckets['j6-haproxy-test'].objects['haproxy.cfg']
maintenance = s3.buckets['j6-haproxy-test'].objects['maintenance.html']
wildcard = s3.buckets['j6-haproxy-test'].objects['wildcard.jazel.net.pem']

# Read content to variable
file_content = obj.read
file_content_maintenance = maintenance.read
file_content_wildcard = wildcard.read

# Log output (optional)
Chef::Log.info(file_content)

# template '/etc/haproxy/haproxy.cfg' do
#   source 'haproxy.cfg.erb'
#   owner 'root'
#   group 'root'
#   mode 0644
#   notifies :restart, "service[haproxy]"
# end

directory "/etc/haproxy/certs/" do
  mode 0644
  owner 'root'
  group 'root'
  action :create
end

file "/etc/haproxy/certs/wildcard.jazel.net.pem" do
  content file_content_wildcard
  owner "root"
  group "root"
  mode 0644
end

file "/etc/haproxy/errors/maintenance.html" do
  content file_content_maintenance
  owner "root"
  group "root"
  mode 0644
end

file "/etc/haproxy/haproxy.cfg" do
  content file_content
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[haproxy]"
end

service 'haproxy' do
  action [:enable, :start]
end
