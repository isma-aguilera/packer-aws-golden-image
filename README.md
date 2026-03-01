# Packer AWS Golden Image

AMI hardened (CIS Level 1) basada en **Amazon Linux 2023**, construida con Packer y con prerequisitos IAM gestionados por Terraform.

Blog: [Packer en AWS: Golden Image con Hardening de Seguridad](https://medium.com/@ismaelaguilera_/packer-en-aws-golden-image-con-hardening-de-seguridad-54bd36fc10ac)

## Prerequisitos

- [Packer](https://developer.hashicorp.com/packer/install) >= 1.11.0
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.13
- Credenciales AWS configuradas (`aws configure` o variables de entorno)

## Despliegue

### 1. Crear recursos IAM (una sola vez)

```bash
make tf-apply
```

Esto crea el rol, instance profile y política IAM que Packer necesita. Adjunta la política `packer-build-policy` al usuario o rol que ejecutará el build.

### 2. Construir la AMI

```bash
make build
```

Este comando inicializa los plugins, valida la configuración y construye la AMI. Al finalizar, el AMI ID queda en `packer/manifest.json`.

### Variables

Se pueden sobreescribir creando un archivo `packer/*.auto.pkrvars.hcl` o pasándolas directamente:

```bash
cd packer && packer build \
  -var 'environment=production' \
  -var 'aws_region=eu-west-1' \
  -var 'instance_type=t3.micro' \
  .
```

| Variable | Default | Descripción |
|---|---|---|
| `aws_region` | `us-east-1` | Región donde se construye y registra la AMI |
| `instance_type` | `t2.micro` | Tipo de instancia para el build |
| `environment` | `develop` | `develop`, `staging` o `production` |
| `encrypt_boot` | `true` | Cifrar el volumen raíz de la AMI |
| `kms_key_id` | `""` | Vacío = clave KMS gestionada por AWS |
| `vpc_id` / `subnet_id` | `""` | Vacío = VPC y subnet por defecto |

### Limpieza

```bash
make tf-destroy   # Eliminar recursos IAM
```

## Qué incluye la AMI

- Actualizaciones de seguridad y paquetes base (SSM Agent, chrony, firewalld, audit)
- SSH hardened: sin root login, sin passwords, cifrado fuerte
- Kernel hardening: sysctl, ASLR, SYN cookies
- Firewall default-deny (solo SSH permitido)
- Auditoría Lynis con score mínimo de 70
- Limpieza de artefactos del build (claves SSH, logs, historial, cloud-init)
