# Análise FinOps de Infraestrutura AWS

Este documento apresenta o mapeamento de recursos cloud e a análise de custos operacionais (FinOps) para os ambientes de **Desenvolvimento (Dev)**, **Homologação (Homog)** e **Produção (Prod)** provisionados via Terraform.

---

## 1. Mapeamento de Recursos e Direcionadores de Custo

### 🛠️ Ambiente: Desenvolvimento (`dev`)
O ambiente de desenvolvimento possui a configuração mais enxuta, focada em validação inicial.

*   **Compute (EC2):**
    *   `app`: 1x `t2.small`
    *   `api`: 1x `t2.micro`
    *   *Nota: Não possui a instância `db` no bloco `local.servers`.*
*   **Banco de Dados (RDS):**
    *   1x `db.t3.micro` (MySQL)
    *   Storage: 30 GB
    *   `multi_az`: **False** (Reduz o custo pela metade comparado a HA).
    *   `snapshot_enviroment`: **False** (Sem custos adicionais agressivos de backup).
*   **Networking:** 1x NAT Gateway (Cobrado por hora de disponibilidade + processamento de dados).
*   **Segurança:** 1x Secrets Manager (Custo mensal fixo baixo + chamadas de API).

### 🧪 Ambiente: Homologação (`homog`)
O ambiente de homologação reflete uma carga mais próxima da produção, introduzindo novos recursos computacionais.

*   **Compute (EC2):**
    *   `app`: 1x `t2.small`
    *   `api`: 1x `t2.micro`
    *   `db`: 1x `t2.medium` *(Adicionado em relação ao ambiente de Dev)*.
*   **Banco de Dados (RDS):**
    *   1x `db.t3.micro` (MySQL)
    *   Storage: 30 GB
    *   `multi_az`: **False**
    *   `snapshot_enviroment`: **False**
*   **Networking:** 1x NAT Gateway.
*   **Segurança:** 1x Secrets Manager.

### 🚀 Ambiente: Produção (`prod`)
O ambiente de produção prioriza Alta Disponibilidade (HA) e Retenção de Dados, o que impacta significativamente o custo final.

*   **Compute (EC2):**
    *   `app`: 1x `t2.small`
    *   `api`: 1x `t2.micro`
    *   `db`: 1x `t2.medium`
*   **Banco de Dados (RDS):**
    *   1x `db.t3.micro` (MySQL)
    *   Storage: 30 GB
    *   `multi_az`: **True** *(Custo de compute e storage do RDS é dobrado para manter a réplica síncrona)*.
    *   `snapshot_enviroment`: **True** *(Gera custos adicionais de armazenamento de snapshots no S3)*.
*   **Networking:** 1x NAT Gateway.
*   **Segurança:** 1x Secrets Manager.

---

## 2. Comparativo de ofensores de custo

| Recurso | Dev | Homog | Prod | Impacto FinOps |
| :--- | :--- | :--- | :--- | :--- |
| **EC2 Instances** | 2 instâncias | 3 instâncias | 3 instâncias | A `t2.medium` (db) adiciona custo extra em Homog/Prod. |
| **RDS Multi-AZ** | Desligado | Desligado | **Ligado** | Dobra o valor do banco de dados em Prod. |
| **RDS Snapshots** | Desligado | Desligado | **Ligado** | Aumenta o custo de storage em Prod. |
| **NAT Gateway** | 1 por AZ | 1 por AZ | 1 por AZ | **Alto impacto contínuo**. Custa ~$32/mês por ambiente só para ficar ligado. |

---

## 3. Recomendações de Otimização (FinOps)

Para maximizar o ROI e evitar desperdícios na AWS, considere as seguintes ações arquiteturais e operacionais:

### 💡 1. Modernização de Família de Instâncias EC2 (Quick Win)
As instâncias da família `t2` são de geração antiga. 
*   **Ação:** Migre de `t2` para `t3` (ou `t3a` com processadores AMD, que são ~10% mais baratas) ou `t4g` (processadores Graviton/ARM, até 20% mais baratas e com melhor performance, caso a aplicação suporte ARM).

### 💡 2. Otimização do NAT Gateway (Alto Impacto)
Atualmente, você está subindo um NAT Gateway dedicado para `dev` e `homog`. O NAT Gateway tem um custo fixo de ~$0.045 por hora (~$32/mês), independentemente do uso.
*   **Ação:** Em ambientes não-produtivos (`dev` e `homog`), substitua o NAT Gateway por uma **NAT Instance** (uma EC2 `t3.nano` configurada como NAT), o que reduzirá o custo de ~$32 para ~$3 ao mês por ambiente.
*   Mantenha o NAT Gateway gerenciado apenas em `prod` pela alta disponibilidade.

### 💡 3. Desligamento Agendado (Scheduling)
Ambientes de `dev` e `homog` não precisam ficar ligados 24/7.
*   **Ação:** Crie uma automação (ex: AWS Instance Scheduler) para desligar as EC2 e o RDS de `dev` e `homog` das 19h às 07h e durante os finais de semana.
*   **Impacto:** Redução de até **65%** no custo de computação e banco de dados desses dois ambientes.

### 💡 4. Instâncias Spot
Para os workers ou aplicações stateless no ambiente de `dev` (como as instâncias `app` e `api`).
*   **Ação:** Modifique o módulo EC2 para aceitar o provisionamento de Instâncias Spot em ambientes de desenvolvimento. Isso pode reduzir o custo de computação em até **90%**.

### 💡 5. Revisão da EC2 "db"
Nos ambientes de `homog` e `prod`, há uma EC2 provisionada com o nome `db` (`t2.medium`), apesar de já existir um módulo dedicado de RDS provisionando um banco de dados na AWS.
*   **Ação:** Avalie se essa EC2 `db` está hospedando algum banco NoSQL (Redis, MongoDB) ou se é um recurso legado. Se for banco de dados relacional, migre os dados para o RDS e desligue a EC2.