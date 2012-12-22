name             "openphoto"
maintainer       "Cameron Johnston"
maintainer_email "cameron@rootdown.net"
license          "Apache 2.0"
description      "Installs/Configures openphoto frontend"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

supports 'ubuntu'

%w{build-essential apt php php-fpm database mysql apache2 nginx}.each do |cb|
  depends cb
end
