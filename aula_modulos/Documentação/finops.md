# Relatório Descritivo de Infraestrutura AWS

Este documento descreve tecnicamente os recursos provisionados na AWS (região `us-east-1` por padrão) através do código Terraform, divididos por ambiente: Desenvolvimento (`dev`), Homologação (`homog`) e Produção (`prod`). 

---

## 1. Ambiente: Desenvolvimento (`dev`)

O ambiente de desenvolvimento é composto por uma rede isolada, recursos computacionais básicos e um banco de dados relacional em instância única.

*   **Rede (VPC `dev-vpc`):**
    *   Bloco CIDR Principal: `10.10.0.0/16`
    *   Sub-rede Pública (`dev-publica`): `10.10.1.0/24`
    *   Sub-rede Privada (`dev-privada`): `10.10.10.0/24`
    *   Sub-redes RDS: `10.10.20.0/24` (AZ-a) e `10.10.21.0/24` (AZ-b)
    *   Conectividade: 1 Internet Gateway (IGW) e 1 NAT Gateway (para saída da rede privada).
*   **Computação (EC2):**
    *   Sistema Operacional: Ubuntu 24.04 LTS (Noble) / Arquitetura x86_64
    *   `app`: 1x `t2.small` (Alocada na sub-rede pública).
    *   `api`: 1x `t2.micro` (Alocada na sub-rede privada).
*   **Banco de Dados (RDS `dev-db`):**
    *   Motor: MySQL 8.0.1
    *   Instância: `db.t3.micro`
    *   Armazenamento: 30 GB
    *   Disponibilidade: Single-AZ (`multi_az = false`)
    *   Backups e Proteção: Snapshot de ambiente e proteção contra exclusão desabilitados.
*   **Segurança e Identidade:**
    *   1x AWS Secrets Manager (`dev-rds`) para gestão de credenciais do banco.
    *   Role e Instance Profile IAM (`ec2_profile_dev`) permitindo às instâncias assumirem a permissão do serviço EC2.

---

## 2. Ambiente: Homologação (`homog`)

O ambiente de homologação possui uma estrutura de rede própria e introduz um recurso computacional adicional em relação ao ambiente de desenvolvimento.

*   **Rede (VPC `homog-vpc`):**
    *   Bloco CIDR Principal: `10.10.0.0/16` (Alocado no módulo)
    *   Sub-rede Pública (`homog-publica`): `10.20.1.0/24`
    *   Sub-rede Privada (`homog-privada`): `10.20.10.0/24`
    *   Sub-redes RDS: `10.20.20.0/24` (AZ-a) e `10.20.21.0/24` (AZ-b)
    *   Conectividade: 1 Internet Gateway e 1 NAT Gateway.
*   **Computação (EC2):**
    *   Sistema Operacional: Ubuntu 24.04 LTS (Noble) / Arquitetura x86_64
    *   `app`: 1x `t2.small` (Alocada na sub-rede pública).
    *   `api`: 1x `t2.micro` (Alocada na sub-rede privada).
    *   `db`: 1x `t2.medium` (Alocada na sub-rede privada).
*   **Banco de Dados (RDS `homog-db`):**
    *   Motor: MySQL 8.0.1
    *   Instância: `db.t3.micro`
    *   Armazenamento: 30 GB
    *   Disponibilidade: Single-AZ (`multi_az = false`)
    *   Backups e Proteção: Snapshot de ambiente e proteção contra exclusão desabilitados.
*   **Segurança e Identidade:**
    *   1x AWS Secrets Manager (`homog-rds`) para gestão de credenciais.

---

## 3. Ambiente: Produção (`prod`)

O ambiente de produção espelha a quantidade de recursos computacionais da homologação, mas implementa configurações de alta disponibilidade e proteção de dados no banco de dados.

*   **Rede (VPC `prod-vpc`):**
    *   Bloco CIDR Principal: `10.30.0.0/16`
    *   Sub-rede Pública (`prod-publica`): `10.30.1.0/24`
    *   Sub-rede Privada (`prod-privada`): `10.30.10.0/24`
    *   Sub-redes RDS: `10.30.20.0/24` (AZ-a) e `10.30.21.0/24` (AZ-b)
    *   Conectividade: 1 Internet Gateway e 1 NAT Gateway.
*   **Computação (EC2):**
    *   Sistema Operacional: Ubuntu 24.04 LTS (Noble) / Arquitetura x86_64
    *   `app`: 1x `t2.small` (Alocada na sub-rede pública).
    *   `api`: 1x `t2.micro` (Alocada na sub-rede privada).
    *   `db`: 1x `t2.medium` (Alocada na sub-rede privada).
*   **Banco de Dados (RDS `prod-db`):**
    *   Motor: MySQL 8.0.1
    *   Instância: `db.t3.micro`
    *   Armazenamento: 30 GB
    *   Disponibilidade: Multi-AZ (`multi_az = true`) - Possui réplica síncrona em uma segunda zona de disponibilidade.
    *   Backups e Proteção: Snapshot de ambiente e proteção contra exclusão habilitados (`snapshot_enviroment = true`, `deletion_protection = true`).
*   **Segurança e Identidade:**
    *   1x AWS Secrets Manager (`prod-rds`) para gestão de credenciais.
    *   Role e Instance Profile IAM (`ec2-profile`) configurados para o ambiente.

<br>
<hr>
<br>

### 💰 Infracost Report

| Project | Monthly Cost |
| :--- | :--- |
| `aws-infrastructure-dev` | $75.65 |
| `aws-infrastructure-homog` | $110.16 |
| `aws-infrastructure-prod` | $128.87 |
| **Total Estimado** | **$314.68** |

<details>
<summary><strong>Ver detalhamento completo dos custos (Tree View)</strong></summary>

```text
Infracost estimate:
