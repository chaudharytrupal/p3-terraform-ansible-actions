# Overview

This document presents comprehensive instructions for the efficient utilization of the Ansible playbook and deploying infra through Terraform.

## Prerequisites

1. **Clone Repository:**

   - Clone the repository to your local machine.

2. **Generate SSH Keys:**

   - Navigate to the Terraform folder.
   - Generate SSH keys using the following commands:
     ```bash
     cd terraform
     ssh-keygen -f key
     ```

3. Update the `variables.tf` file in the Terraform folder:
   - Go to line 48 and customize the bucket name.
   - In `config.tf` at line 3, change the bucket name for the S3 backend remote state (manually create the bucket).

## Terraform Usage

- Deploy your Terraform infrastructure with the specified environment (e.g., `terraform apply -auto-approve -var="env=prod"`). Omit the `-var` argument for the default staging environment.
- To delete the infrastucture - `terraform destory -auto-approve` (The S3 bucket won't delete since it's not empty and needs to be done manually)

## Ansible Usage

1. **Changes in Ansible Folder:**

   - Change your working directory to the Ansible folder.
   - In the `roles/shared/vars/main.yml` file, replace the existing bucket name with the one used in step 3 for variables.tf.
   - For uploading photos to S3 and using them in the webserver:
     1. Modify the `main.yml` file in `roles/uploadtos3/tasks` to set the local folder path containing photos ("fileroot" option).
     2. In `roles/modifyindexpage/templates/index.j2`, update lines 67 and 68 with the S3 image URLs. Add similar lines for more images. (see the lines below)
        ```
        <img src="https://{{ shared_s3bucketname }}.s3.amazonaws.com/<write the name of your image file #1>.png" alt="">
        <img src="https://{{ shared_s3bucketname }}.s3.amazonaws.com/<write the name of your image file #2>.png" alt="">
        ```

2. **Enable AWS EC2 Plugin:**

   - Ensure the `aws_ec2` plugin is added to the `enabled_plugins` line in the `/etc/ansible/ansible.cfg` file. If the file is empty (for newer Ansible versions on MacOS), leave it as is. (Also install boto3 if not already for dynamic inventory)
   - Add 'host_key_checking = False' in the `ansible.cfg` file or run:
     ```bash
     export ANSIBLE_HOST_KEY_CHECKING=False
     ```

3. **Generate Inventory Graph:**

   - Use the following command to generate an inventory graph from the provided AWS EC2 inventory file (`di.aws_ec2.yml`):
     ```bash
     ansible-inventory -i di.aws_ec2.yml --graph
     ```

4. **Run Ansible Playbook:**
   - Execute the Ansible playbook with the following command:
     ```bash
     ansible-playbook -i di.aws_ec2.yml playbook.yml
     ```

### Other Information

- The ansible part has been tested and developed with version > 2.13 for the dynamic inventory plugin and the community.aws.s3_sync to work. If the version dependency is not met, additional troubleshooting will be required. Also the `[default]` credential set is being used for dynamic inventory
