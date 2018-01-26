#
# Cookbook Name:: nomad
# Recipe:: manage
#
# Copyright 2015-2018, Nathan Williams <nath.e.will@gmail.com>
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

args = Nomad::Helpers.hash_to_arg_string(node['nomad']['daemon_args'])

systemd_unit 'nomad.service' do
  content({
    'Unit' => {
      'Description' => 'Nomad Cluster Manager',
      'Documentation' => 'https://www.nomadproject.io/docs/index.html'
    },
    'Install' => {
      'WantedBy' => 'multi-user.target',
    },
    'Service' => {
      'ExecStart' => "/usr/local/bin/nomad agent #{args}"
      'Restart' => 'on-failure'
    }
  })
  only_if do
    File.exist?('/proc/1/comm') && IO.read('/proc/1/comm').chomp == 'systemd'
  end
  action :create
end

template '/etc/init/nomad.conf' do
  source 'upstart.conf.erb'
  variables daemon_args: args
  action :create
  only_if { ::File.executable?('/sbin/initctl') }
end

service 'nomad' do
  if ::File.executable?('/sbin/initctl')
    provider Chef::Provider::Service::Upstart
  end
  action %i[enable start]
end
