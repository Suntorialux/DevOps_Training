# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
COUNT_SERVERS = 3

$install_httpd = <<SCRIPT
  echo "***********************************************************"
  echo "*             Installing Apache HTTP Server"
  echo "***********************************************************"

  yum -y install httpd
  
  systemctl start httpd
  
  cp /vagrant/mod_jk.so /etc/httpd/modules/
  
  echo "worker.list=lb" > /etc/httpd/conf/workers.properties
  echo "worker.lb.type=lb" >> /etc/httpd/conf/workers.properties
  
  for ((c=0 ; c<#{COUNT_SERVERS}-1; c++))
  do 
    ind=`expr $c + 1`
    array[$c]="worker${ind}"
  done
  
  param=$(IFS=, ; echo "${array[*]}")
  
  echo "worker.lb.balance_workers=${param}" >> /etc/httpd/conf/workers.properties
  
  for ((c=0 ; c<#{COUNT_SERVERS}-1; c++))
  do 
    ind=`expr $c + 1`
    echo "worker.worker${ind}.host=server${ind}" >> /etc/httpd/conf/workers.properties
    echo "worker.worker${ind}.port=8009" >> /etc/httpd/conf/workers.properties
    echo "worker.worker${ind}.type=ajp13" >> /etc/httpd/conf/workers.properties
  done
  
  echo "LoadModule jk_module modules/mod_jk.so" >> /etc/httpd/conf/httpd.conf 
  echo "JkWorkersFile conf/workers.properties" >> /etc/httpd/conf/httpd.conf 
  echo "JkShmFile /tmp/shm" >> /etc/httpd/conf/httpd.conf 
  echo "JkLogFile logs/mod_jk.log" >> /etc/httpd/conf/httpd.conf 
  echo "JkLogLevel info" >> /etc/httpd/conf/httpd.conf 
  echo "JkMount /test* lb" >> /etc/httpd/conf/httpd.conf 
  
  systemctl restart httpd
  
  
SCRIPT

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bertvv/centos72"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
    vb.gui = true
  #   # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end
  
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  
  (1..COUNT_SERVERS).each do |i|
    config.vm.define "server#{i}" do |server|
      server.vm.hostname = "server#{i}"
      server.vm.network "private_network", ip: "172.20.20.1#{i}"

      # Autoconfigure hosts. This will copy the private network addresses from
      # each VM and update hosts entries on all other machines. No further
      # configuration is needed.
      # To use, please, run this command:
      #      vagrant plugin install vagrant-hosts
      server.vm.provision :hosts, :sync_hosts => true

      if i == COUNT_SERVERS
        server.vm.network "forwarded_port", guest: 80, host: "1808#{i}"
        server.vm.provision "shell", inline: $install_httpd
      else
        server.vm.provision :shell, :path => "install_env.sh"
        server.vm.provision "shell", 
          inline: " mkdir /usr/share/tomcat/webapps/test#{i}
                    echo \"SERVER_#{i}\" > /usr/share/tomcat/webapps/test#{i}/index.html"
      end
      server.vm.provision "shell", inline: "systemctl stop firewalld"
#        inline: "firewall-cmd --zone=public --add-port=1808#{i}/tcp --permanent
#                 firewall-cmd --zone=public --add-port=80/tcp --permanent
#                 firewall-cmd --zone=public --add-port=8080/tcp --permanent
#                 firewall-cmd --zone=public --add-port=8009/tcp --permanent
#                 firewall-cmd --reload"
    end
  end
end
