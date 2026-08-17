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
Infracost estimate: Monthly Cost

Project: aws-infrastructure-dev

 Name                                                          Monthly Qty  Unit            Monthly Cost
                                                                          
 aws_instance.app                                                         
 ├─ Instance usage (Linux/UNIX, on-demand, t2.small)                   730  hours                 $16.79
 └─ root_block_device (gp3)                                              8  GB                     $0.64
                                                                          
 aws_instance.api                                                         
 ├─ Instance usage (Linux/UNIX, on-demand, t2.micro)                   730  hours                  $8.47
 └─ root_block_device (gp3)                                              8  GB                     $0.64
                                                                          
 aws_db_instance.main                                                     
 ├─ Database instance (on-demand, Single-AZ, db.t3.micro)              730  hours                 $12.41
 └─ Storage (gp2)                                                       30  GB                     $3.45
                                                                          
 aws_nat_gateway.main                                                     
 ├─ NAT Gateway hours                                                  730  hours                 $32.85
 └─ Data processing                                                      0  GB                     $0.00
                                                                          
 aws_secretsmanager_secret.main                                           
 ├─ Secret                                                               1  months                 $0.40
 └─ API requests                                                         0  10k requests           $0.00

 PROJECT TOTAL                                                                                    $75.65

---------------------------------------------------------------------------------------------------------

Project: aws-infrastructure-homog

 Name                                                          Monthly Qty  Unit            Monthly Cost
                                                                          
 aws_instance.app                                                         
 ├─ Instance usage (Linux/UNIX, on-demand, t2.small)                   730  hours                 $16.79
 └─ root_block_device (gp3)                                              8  GB                     $0.64
                                                                          
 aws_instance.api                                                         
 ├─ Instance usage (Linux/UNIX, on-demand, t2.micro)                   730  hours                  $8.47
 └─ root_block_device (gp3)                                              8  GB                     $0.64

 aws_instance.db                                                         
 ├─ Instance usage (Linux/UNIX, on-demand, t2.medium)                  730  hours                 $33.87
 └─ root_block_device (gp3)                                              8  GB                     $0.64
                                                                          
 aws_db_instance.main                                                     
 ├─ Database instance (on-demand, Single-AZ, db.t3.micro)              730  hours                 $12.41
 └─ Storage (gp2)                                                       30  GB                     $3.45
                                                                          
 aws_nat_gateway.main                                                     
 ├─ NAT Gateway hours                                                  730  hours                 $32.85
 └─ Data processing                                                      0  GB                     $0.00
                                                                          
 aws_secretsmanager_secret.main                                           
 ├─ Secret                                                               1  months                 $0.40
 └─ API requests                                                         0  10k requests           $0.00

 PROJECT TOTAL                                                                                   $110.16

---------------------------------------------------------------------------------------------------------

Project: aws-infrastructure-prod

 Name                                                          Monthly Qty  Unit            Monthly Cost
                                                                          
 aws_instance.app                                                         
 ├─ Instance usage (Linux/UNIX, on-demand, t2.small)                   730  hours                 $16.79
 └─ root_block_device (gp3)                                              8  GB                     $0.64
                                                                          
 aws_instance.api                                                         
 ├─ Instance usage (Linux/UNIX, on-demand, t2.micro)                   730  hours                  $8.47
 └─ root_block_device (gp3)                                              8  GB                     $0.64

 aws_instance.db                                                         
 ├─ Instance usage (Linux/UNIX, on-demand, t2.medium)                  730  hours                 $33.87
 └─ root_block_device (gp3)                                              8  GB                     $0.64
                                                                          
 aws_db_instance.main                                                     
 ├─ Database instance (on-demand, Multi-AZ, db.t3.micro)               730  hours                 $24.82
 └─ Storage (gp2, Multi-AZ)                                             30  GB                     $6.90
 └─ Backup storage (Snapshot Environment)                               30  GB                     $2.85
                                                                          
 aws_nat_gateway.main                                                     
 ├─ NAT Gateway hours                                                  730  hours                 $32.85
 └─ Data processing                                                      0  GB                     $0.00
                                                                          
 aws_secretsmanager_secret.main                                           
 ├─ Secret                                                               1  months                 $0.40
 └─ API requests                                                         0  10k requests           $0.00

 PROJECT TOTAL                                                                                   $128.87