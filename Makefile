PACKER_DIR    := packer
TERRAFORM_DIR := terraform

.DEFAULT_GOAL := help

.PHONY: help tf-init tf-apply tf-destroy init validate build

help: ## Mostrar targets disponibles
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

# --- Terraform: prerequisitos IAM ---

tf-init: ## Inicializar Terraform (descarga el provider de AWS)
	cd $(TERRAFORM_DIR) && terraform init

tf-apply: tf-init ## Crear los recursos IAM en AWS
	cd $(TERRAFORM_DIR) && terraform apply

tf-destroy: ## Eliminar los recursos IAM creados por Terraform
	cd $(TERRAFORM_DIR) && terraform destroy

# --- Packer: build de la AMI ---

init: ## Descargar plugins de Packer
	cd $(PACKER_DIR) && packer init .

validate: init ## Validar la configuración de Packer (sin llamadas a AWS)
	cd $(PACKER_DIR) && packer validate .

build: validate ## Construir la AMI en AWS
	cd $(PACKER_DIR) && packer build .
