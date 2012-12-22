#
# Cookbook Name:: openphoto
# Recipe:: nginx
#
# Copyright 2012, Cameron Johnston
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

include_recipe 'openphoto::default'
include_recipe 'nginx'

template ::File.join(node['nginx']['dir'],'sites-available','openphoto.conf') do
  source 'openphoto-nginx.conf.erb'
  owner node['nginx']['user']
  group node['nginx']['group']
end

nginx_site 'openphoto.conf'
