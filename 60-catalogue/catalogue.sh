
component=$1
dnf install ansible -y
ansible-pull -U https://github.com/MAHALAKSHMImahalakshmi/rolesAnsibleRoboshop-tf.git -e component=$1 -e env=$2 main.yaml