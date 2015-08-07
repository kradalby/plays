upgrade:
	ansible-playbook upgrade.yml -i inventory

boot:
	ansible-playbook bootstrap.yml -i inventory

ping:
	ansible all -m ping -i inventory
