Vagrant.configure("2") do |config|
  config.vm.define "master" do |master|
	master.vm.box = "generic/debian10"
  	master.vm.hostname = "node1"
  	master.vm.network "private_network", ip: "10.100.101.100"
	end
 config.vm.define "etcd" do |etcd|
	etcd.vm.box = "generic/debian10"
  	etcd.vm.hostname = "node2"
  	etcd.vm.network "private_network", ip: "10.100.101.101"
	  etcd.vm.provider "virtualbox" do |vb|
        vb.memory="2048"
        end
	end
 config.vm.define "worker" do |worker|
	worker.vm.box = "generic/debian10"
	worker.vm.hostname = "node3"
	worker.vm.network "private_network", ip: "10.100.101.102"
        worker.vm.provider "virtualbox" do |vb|
        vb.memory="4096"
        end
        end
end
