#Automation Deploy OpenStack Using Kolla-ansible
#OpenStack(Zed)

#Install dependencies
sudo apt update
sudo apt install -y git python3-dev libffi-dev gcc libssl-dev

#Install dependencies for the virtual environment
sudo apt install -y python3-venv
python3 -m venv ubuntu
source ubuntu/bin/activate
pip install -U pip
pip install 'ansible-core>=2.13,<=2.14.2'
pip install 'ansible>=6,<8'

#Install Kolla-ansible
pip install git+https://opendev.org/openstack/kolla-ansible
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla
cp -r ubuntu/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp ubuntu/share/kolla-ansible/ansible/inventory/all-in-one .

#Install Ansible Galaxy requirements
kolla-ansible install-deps

#Prepare initial configuration
kolla-genpwd
cp /etc/kolla/globals.yml /etc/kolla/globals.yml.bak
rm /etc/kolla/globals.yml
echo "  kolla_base_distro: "ubuntu"
		openstack_tag_suffix: "-aarch64"
		network_interface: "ens33"
		neutron_external_interface: "ens34"
		kolla_internal_vip_address: "192.168.1.254"
		" >> /etc/kolla/globals.yml
		
#Deployment
kolla-ansible -i ./all-in-one bootstrap-servers
kolla-ansible -i ./all-in-one prechecks
kolla-ansible -i ./all-in-one deploy

#Using OpenStack
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/
kolla-ansible post-deploy