# Terraform Docs

Documentação consolidada dos módulos Terraform utilizados no projeto.

Esta documentação foi gerada utilizando o [terraform-docs](https://terraform-docs.io/).

## Módulos

### VPC

Responsável pela criação da infraestrutura de rede, incluindo VPC,
subnets públicas, privadas e subnets destinadas ao RDS.

[Ver documentação completa da VPC](./vpc.md)

---

### EC2

Responsável pela criação e configuração das instâncias EC2.

[Ver documentação completa da EC2](./ec2.md)

---

### RDS

Responsável pela criação e configuração do banco de dados RDS.

[Ver documentação completa do RDS](./rds.md)

---

### Security Group

Responsável pelas regras de controle de tráfego da infraestrutura.

[Ver documentação completa dos Security Groups](./security-group.md)

---

### NAT Gateway

Responsável por permitir que recursos da rede privada tenham acesso
de saída à Internet.

[Ver documentação completa do NAT Gateway](./nat-gateway.md)

---

### Internet Gateway

Responsável pela conectividade entre a VPC e a Internet.

[Ver documentação completa do Internet Gateway](./igw.md)

---

### Secrets Manager

Responsável pelo gerenciamento de credenciais utilizadas pela infraestrutura.

[Ver documentação completa do Secrets Manager](./secrets-manager.md)