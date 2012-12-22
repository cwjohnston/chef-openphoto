#
# Cookbook Name:: openphoto
# Recipe:: default
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

include_recipe 'build-essential'

node.set['php']['directives'].merge!({
  'file_uplaods' => 'On',
  'upload_max_file_size' => '16M',
  'post_max_size' => '16M'
})

include_recipe 'php'

%w{ git
    curl
    imagemagick
    libpcre3-dev
    exiftran
    php5-dev
    php5-curl
    php5-mcrypt
    php5-mysql
    php-pear
    php-apc
    php5-imagick }.each do |pkg|
  package pkg
end

php_pear_channel 'pecl.php.net' do
  action :update
end

php_pear 'oauth' do
  action :install
end

include_recipe 'php-fpm'
  
group node['openphoto']['group']

user node['openphoto']['user'] do
  gid node['openphoto']['group']
  system true
end

[ node['openphoto']['install_dir'],
  ::File.join(node['openphoto']['data_dir'],'userdata'),
  ::File.join(node['openphoto']['data_dir'],'photos'),
  ::File.join(node['openphoto']['data_dir'],'cache') ].each do |dir|
  directory dir do
    owner node['openphoto']['user']
    group node['openphoto']['group']
    recursive true
  end
end

git node['openphoto']['install_dir'] do
  repo node['openphoto']['repo']
  revision node['openphoto']['revision']
  user node['openphoto']['user']
  group node['openphoto']['group']
  action :checkout
end

link ::File.join(node['openphoto']['install_dir'],'src','userdata') do
  to ::File.join(node['openphoto']['data_dir'],'userdata')
end

link ::File.join(node['openphoto']['install_dir'],'src','html','photos') do
  to ::File.join(node['openphoto']['data_dir'],'photos')
end

link ::File.join(node['openphoto']['install_dir'],'src','html','assets','cache') do
  to ::File.join(node['openphoto']['data_dir'],'cache')
end

case node['openphoto']['http_flavor']
when 'nginx'
  include_recipe 'nginx'

  template ::File.join(node['nginx']['dir'],'sites-available','openphoto.conf') do
    source 'openphoto-nginx.conf.erb'
    owner node['nginx']['user']
    group node['nginx']['group']
  end

  nginx_site 'openphoto.conf'

when 'apache','apache2'
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
  
end

case node['openphoto']['database_flavor']
when 'mysql'
  include_recipe 'mysql::ruby'
  
  if node.has_key?('ec2')
    include_recipe 'mysql::server_ec2'
  else
    include_recipe 'mysql::server'
  end

  include_recipe 'database'
  
  mysql_connection_info = {:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']}

  mysql_database 'openphoto' do
    connection mysql_connection_info
    action :create
  end
end
