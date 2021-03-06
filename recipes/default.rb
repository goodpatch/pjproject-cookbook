#
# Cookbook Name:: pjproject-cookbook
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

source_version = "2.4.5"
source_extension = ".tar.bz2"
source_tarball = "pjproject-#{source_version}.tar.bz2"
source_url_prefix = "http://www.pjsip.org/release/#{source_version}/"
source_url = node['pjproject']['source']['url'] || source_url_prefix + source_tarball
source_path = "#{Chef::Config['file_cache_path'] || '/tmp'}/#{source_tarball}"

prefix = node['pjproject']['arch'] === 'x64' ? "/usr/lib64" : "/usr/lib"

%w{gcc-c++ make uuid-devel libuuid-devel gsm-devel}.each do |pkg|
	package pkg do
		action :install
	end
end

remote_file source_tarball do
  source source_url
  path source_path
  backup false
end

bash "install_pjproject" do
  user "root"
  cwd File.dirname(source_path)
  code <<-EOH
    mkdir pjproject
    bzip2 -dc #{source_path} | tar xvf - -C pjproject --strip-components=1
    cd pjproject
    ./configure --libdir=#{prefix} --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr --with-external-gsm CFLAGS='-O2 -DNDEBUG'
    make dep
    make
    make install
    ldconfig
  EOH
end
