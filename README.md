1) Copy the ansible directory to ansible controller
2) Update the below vars in group_vars 

vi ansible/group_vars/all

jenkins_url: jenkins_url:port
user_name: username
password: password ot token

3) Run the below shell file to create the folder structure :
sh make_folder_structure.sh

4) Run the below command to create the Jobs 
ansible-playbook create_jenkins_job_workflow.yml
ansible-playbook ecs-migrate.yml --extra-vars "@app-template/app_name"
