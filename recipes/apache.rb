#
# Cookbook Name:: openphoto
# Recipe:: apache
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


include_recipe 'apache2'
include_recipe 'apache2::mod_php5'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_deflate'
include_recipe 'apache2::mod_expires'
include_recipe 'apache2::mod_headers'

template ::File.join(node['apache']['dir'],'sites-available','openphoto.conf') do
  source 'openphoto-apache2.conf.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

apache_site 'openphoto.conf'

