# Checkov — Correções e Exceções

## 1. Objetivo

Este documento registra a análise de segurança realizada com o **Checkov** no projeto Terraform, as correções aplicadas e os checks que foram deliberadamente ignorados.

O objetivo é demonstrar a aplicação de boas práticas de segurança e IaC no projeto de **portfólio**, sem tratar a infraestrutura como um ambiente de produção real.

Os `skip` utilizados neste projeto representam decisões de escopo. Eles não significam que os controles sejam desnecessários em ambientes reais.

---

## 2. O que é o Checkov

O **Checkov** é uma ferramenta de análise estática de segurança para Infrastructure as Code (IaC).

Neste projeto, ele foi utilizado para analisar os arquivos Terraform e identificar configurações que poderiam representar riscos ou que não seguem determinadas boas práticas de segurança da AWS.

A execução utilizada foi feita sobre os ambientes Terraform:

```powershell
checkov -d .\enviroments
```

O resultado foi salvo em:

```text
checkov-results.txt
```

Para atualizar o relatório, o arquivo anterior é removido antes de uma nova execução:

```powershell
Remove-Item .\checkov-results.txt -ErrorAction SilentlyContinue
```

---

# 3. Principais correções realizadas

Durante a análise do Checkov, algumas recomendações foram implementadas diretamente no Terraform.

## 3.1. IAM Role para as instâncias EC2

Foi adicionada uma IAM Role para as instâncias EC2, juntamente com um Instance Profile.

### Implementação

```hcl
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}
```

O Instance Profile passou a ser utilizado pelas instâncias EC2:

```hcl
iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
```

No módulo EC2, a variável correspondente foi criada:

```hcl
variable "iam_instance_profile" {
  type = string
}
```

### Motivo

A utilização de IAM Role/Instance Profile permite que permissões sejam associadas à instância por meio do IAM, evitando a necessidade de armazenar credenciais AWS diretamente na EC2.

---

## 3.2. IMDSv2 nas instâncias EC2

Foi adicionada a configuração de Metadata Options:

```hcl
metadata_options {
  http_endpoint = "enabled"
  http_tokens   = "required"
}
```

### Motivo

A configuração exige tokens para acesso ao Instance Metadata Service, utilizando o IMDSv2.

Isso reduz a exposição a determinados tipos de ataques relacionados ao acesso ao metadata service da EC2.

---

## 3.3. Criptografia do volume raiz da EC2

Foi adicionada criptografia ao volume raiz:

```hcl
root_block_device {
  encrypted = true
}
```

### Motivo

Os dados armazenados no volume raiz da EC2 passam a utilizar criptografia.

---

## 3.4. Monitoramento da EC2

Foi habilitado:

```hcl
monitoring = true
```

### Motivo

O monitoramento detalhado permite obter métricas adicionais da instância EC2 e melhora a capacidade de observabilidade da infraestrutura.

---

# 4. Correções realizadas no RDS

O módulo RDS recebeu diversas configurações de segurança, disponibilidade e monitoramento.

## 4.1. Criptografia do armazenamento

```hcl
storage_encrypted = true
```

### Motivo

O armazenamento do RDS passa a utilizar criptografia.

---

## 4.2. Atualização automática de versões menores

```hcl
auto_minor_version_upgrade = true
```

### Motivo

Permite a aplicação automática de atualizações de versões menores do mecanismo do banco.

---

## 4.3. Enhanced Monitoring

Foi configurado:

```hcl
monitoring_interval = 60
```

E a role de monitoramento é utilizada:

```hcl
monitoring_role_arn = aws_iam_role.rds_monitoring.arn
```

### Motivo

Permite obter métricas adicionais de monitoramento do RDS.

---

## 4.4. Performance Insights

```hcl
performance_insights_enabled = true
```

### Motivo

Habilita recursos adicionais para análise do desempenho do banco de dados.

---

## 4.5. Proteção contra exclusão

```hcl
deletion_protection = true
```

### Motivo

Reduz o risco de exclusão acidental da instância RDS.

---

## 4.6. Logs do RDS

Foram habilitadas exportações para CloudWatch:

```hcl
enabled_cloudwatch_logs_exports = [
  "error",
  "general",
  "slowquery"
]
```

### Motivo

Permite centralizar determinados logs do banco para facilitar observabilidade e análise.

---

## 4.7. Tags nos snapshots

Foi configurado:

```hcl
copy_tags_to_snapshot = true
```

### Motivo

Mantém as tags associadas aos snapshots, facilitando identificação e organização dos recursos.

---

## 4.8. Snapshot final

O RDS foi configurado para manter um snapshot final:

```hcl
skip_final_snapshot = false
final_snapshot_identifier = var.name_snapshot_final
```

### Motivo

Permite preservar um snapshot final antes da destruição do banco.

---

## 4.9. RDS sem acesso público

Foi configurado:

```hcl
publicly_accessible = false
```

### Motivo

O banco de dados não deve ser diretamente acessível pela Internet.

---

## 4.10. Multi-AZ

O módulo RDS utiliza uma variável para permitir definir a disponibilidade por ambiente:

```hcl
multi_az = var.multi_az
```

No ambiente de produção, a configuração pode ser habilitada:

```hcl
multi_az = true
```

No ambiente de homologação, o projeto utiliza uma configuração diferente por se tratar de um ambiente de portfólio.

---

# 5. Security Groups

O projeto possui Security Groups separados para aplicação e banco.

O Security Group do RDS permite somente a comunicação MySQL na porta 3306 proveniente do Security Group da aplicação:

```hcl
ingress {
  description     = "MySQL vindo direto da aplicação"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  security_groups = [aws_security_group.web.id]
}
```

### Motivo

Em vez de liberar a porta 3306 para um CIDR amplo, o acesso ao banco é limitado ao Security Group da aplicação.

Isso representa uma segmentação de rede mais adequada para a arquitetura proposta.

---

# 6. Checks ignorados

Alguns checks do Checkov foram ignorados porque o projeto possui finalidade de **portfólio/laboratório**, e determinadas funcionalidades adicionariam complexidade ou custos que não são necessários para demonstrar os objetivos principais do projeto.

Os skips utilizados no comando foram:

```text
CKV_AWS_119
CKV_AWS_135
CKV_AWS_354
CKV_AWS_382
CKV_AWS_260
CKV2_AWS_62
CKV2_AWS_61
CKV_AWS_18
CKV_AWS_145
CKV_AWS_144
CKV_AWS_157
CKV2_AWS_11
CKV2_AWS_5
```

## CKV_AWS_157 — RDS Multi-AZ

**Descrição:** Ensure that RDS instances have Multi-AZ enabled.

Este check foi ignorado porque o ambiente de homologação do projeto não precisa representar uma arquitetura de alta disponibilidade de produção.

A configuração continua sendo parametrizada no módulo RDS:

```hcl
multi_az = var.multi_az
```

Dessa forma, o projeto consegue utilizar Multi-AZ quando necessário, especialmente em um ambiente de produção.

---

## CKV2_AWS_11 — VPC Flow Logs

**Descrição:** Ensure VPC flow logging is enabled in all VPCs.

Foi ignorado porque VPC Flow Logs não fazem parte do escopo atual do laboratório de portfólio.

A implementação pode ser adicionada posteriormente como uma melhoria de observabilidade e segurança.

---

## CKV2_AWS_5 — Security Groups associados a recursos

**Descrição:** Ensure that Security Groups are attached to another resource.

O Checkov apresentou esse finding porque os Security Groups são criados em um módulo e utilizados por outros módulos.

A arquitetura utiliza os Security Groups nos recursos EC2 e RDS, porém a análise estática pode não conseguir identificar corretamente todas essas associações através da composição dos módulos Terraform.

Por isso, o check foi tratado como uma exceção de análise para este projeto.

---

## CKV_AWS_119

Relacionado à utilização de uma chave KMS própria para determinados recursos.

Foi ignorado devido ao escopo do projeto de portfólio. A infraestrutura utiliza mecanismos de criptografia onde foram considerados necessários, mas não foi criada uma estrutura completa de gerenciamento de chaves KMS dedicadas para todos os recursos.

---

## CKV_AWS_135

Relacionado à configuração de EBS Optimized.

Foi ignorado por não ser um requisito central do laboratório e por não representar uma prioridade dentro do escopo atual do projeto.

---

## CKV_AWS_354

Relacionado à utilização de KMS para Performance Insights.

O Performance Insights foi habilitado no RDS:

```hcl
performance_insights_enabled = true
```

Porém, a utilização de uma chave KMS dedicada para esse recurso não faz parte do escopo atual do projeto de portfólio.

---

## CKV_AWS_382

Relacionado à regra de saída ampla (`egress`) dos Security Groups.

O projeto mantém:

```hcl
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
```

Essa configuração permite saída para a Internet.

O check foi ignorado porque o objetivo do projeto é demonstrar uma infraestrutura AWS funcional e a restrição completa de egress não faz parte do escopo atual.

Em uma infraestrutura de produção, as regras de saída poderiam ser restringidas conforme os requisitos da aplicação.

---

## CKV_AWS_260

Relacionado à exposição de HTTP.

O Security Group web possui acesso HTTP:

```hcl
from_port   = 80
to_port     = 80
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
```

O check foi ignorado porque o projeto possui finalidade de laboratório/portfólio e demonstra uma aplicação web acessível pela Internet.

Em produção, o ideal seria avaliar a necessidade de HTTP e, quando possível, utilizar HTTPS e redirecionamento.

---

## CKV2_AWS_62

Relacionado a notificações de eventos do S3.

Foi ignorado porque a arquitetura atual do projeto não utiliza notificações de eventos do S3 como requisito funcional.

---

## CKV2_AWS_61

Relacionado à configuração de lifecycle no S3.

Foi ignorado porque o projeto não possui atualmente uma política de ciclo de vida do S3 como requisito.

Essa configuração poderia ser adicionada posteriormente para gerenciamento de custos e retenção.

---

## CKV_AWS_18

Relacionado à utilização de access logging no S3.

Foi ignorado porque o logging de acesso do bucket não faz parte do escopo atual do projeto de portfólio.

---

## CKV_AWS_145

Relacionado à utilização de KMS no S3.

Foi ignorado porque o projeto utiliza criptografia padrão do S3, mas não possui uma chave KMS dedicada como requisito.

---

## CKV_AWS_144

Relacionado à replicação Cross-Region do S3.

Foi ignorado porque o projeto não possui requisito de Disaster Recovery entre regiões.

A replicação entre regiões aumentaria a complexidade e os custos sem agregar valor proporcional ao objetivo atual do laboratório.

---

# 7. Filosofia utilizada para os skips

Os `skip` não foram utilizados para simplesmente esconder todos os resultados do Checkov.

A estratégia adotada foi:

```text
Finding
   │
   ├── É importante para a arquitetura?
   │       │
   │       └── SIM → Corrigir
   │
   └── Está fora do escopo do portfólio?
           │
           └── SIM → Skip documentado
```

Dessa forma, o projeto demonstra que os findings foram analisados individualmente e que existe uma justificativa para as exceções.

---

# 8. Resultado esperado

Após as correções e os skips definidos, o Checkov deve deixar de reportar os findings que foram tratados.

O objetivo não é simplesmente obter:

```text
0 findings
```

mas demonstrar que:

- os problemas relevantes foram corrigidos;
- os controles de segurança importantes foram implementados;
- as exceções foram identificadas;
- as exceções possuem justificativa;
- a infraestrutura foi construída considerando segurança desde o código;
- o Terraform foi submetido a uma ferramenta de análise estática.

---

# 9. Comando utilizado

Para executar a análise e substituir o relatório anterior:

```powershell
Remove-Item .\checkov-results.txt -ErrorAction SilentlyContinue

checkov -d .\enviroments `
  --skip-check CKV_AWS_157 `
  --skip-check CKV2_AWS_11 `
  --skip-check CKV2_AWS_5 `
  --skip-check CKV_AWS_119 `
  --skip-check CKV_AWS_135 `
  --skip-check CKV_AWS_354 `
  --skip-check CKV_AWS_382 `
  --skip-check CKV_AWS_260 `
  --skip-check CKV2_AWS_62 `
  --skip-check CKV2_AWS_61 `
  --skip-check CKV_AWS_18 `
  --skip-check CKV_AWS_145 `
  --skip-check CKV_AWS_144 `
  > .\checkov-results.txt
```

O comando remove o relatório anterior e gera um novo arquivo:

```text
checkov-results.txt
```

---

# 10. Conclusão

A análise com Checkov foi utilizada como uma etapa de segurança do projeto Terraform.

Durante a revisão, foram implementadas melhorias relacionadas a:

- IAM Role e Instance Profile;
- IMDSv2;
- criptografia dos volumes EC2;
- monitoramento das EC2;
- criptografia do RDS;
- monitoramento do RDS;
- Performance Insights;
- proteção contra exclusão;
- exportação de logs;
- snapshots;
- acesso privado ao RDS;
- segmentação por Security Groups.

Os demais findings foram analisados e alguns foram deliberadamente ignorados por estarem fora do escopo de um projeto de portfólio.

As exceções não representam uma recomendação para ambientes de produção. Em um cenário real, controles como Multi-AZ, VPC Flow Logs, KMS dedicado, lifecycle, logging e Disaster Recovery poderiam ser necessários de acordo com os requisitos de segurança, disponibilidade, compliance e negócio.
