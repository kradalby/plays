upgrade:
	ansible-playbook upgrade.yaml -i inventory

boot:
	ansible-playbook bootstrap.yaml -i inventory

ping:
	ansible all -m ping -i inventory
