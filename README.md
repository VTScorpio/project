# Platformă de Monitorizare DevOps

Acest proiect monitorizează utilizarea CPU, RAM, disk și procese și salvează loguri și backup-uri în containere Docker.

## Tehnologii
- Bash, Python
- Docker, Docker Compose
- Jenkins (CI/CD)
- Ansible (config management)
- AWS + Terraform (infrastructură)

## Rulare locală
```bash
bash setup.sh




1. Creează credentiale DockerHub

Manage Jenkins → Credentials → (global) → Add Credentials

Type: Username + Password

ID: dockerhub



2. Creează user nou pentru proiect

Manage Jenkins → Manage Users → Create User

Dă-i permisiuni doar la:

Job/Read

Build/Run

Workspace


3. Creează View personalizat

În Dashboard:

+ New View

Nume: PlatformaMonitorizare

Tip: List View

Selectează joburile relevante


1. Documentație

Include exemple clare pentru rulare locală:

bash setup.sh
docker compose up -d


și cum se aplică Ansible:

ansible-playbook -i ansible/inventory.ini ansible/install-docker.yml
ansible-playbook -i ansible/inventory.ini ansible/run-platform.yml