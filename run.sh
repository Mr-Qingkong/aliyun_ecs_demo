cd ./ansible
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_TF_DIR=..
export ANSIBLE_NOCOWS=1
chmod +x terraform.py
ansible-playbook -i ./terraform.py playbook.yml
