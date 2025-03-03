# 1. terraform-docs 
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.89.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.89.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 20.31 |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | terraform-aws-modules/eks/aws//modules/karpenter | n/a |
| <a name="module_karpenter_disabled"></a> [karpenter\_disabled](#module\_karpenter\_disabled) | terraform-aws-modules/eks/aws//modules/karpenter | n/a |
| <a name="module_load_balancer_irsa_role"></a> [load\_balancer\_irsa\_role](#module\_load\_balancer\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/5.89.0/docs/resources/eip) | resource |
| [helm_release.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_deployment.springboot](https://registry.terraform.io/providers/hashicorp/kubernetes/2.4/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.springboot](https://registry.terraform.io/providers/hashicorp/kubernetes/2.4/docs/resources/ingress_v1) | resource |
| [kubernetes_manifest.karpenter_ec2_node_class_1](https://registry.terraform.io/providers/hashicorp/kubernetes/2.4/docs/resources/manifest) | resource |
| [kubernetes_manifest.karpenter_ec2_node_class_2](https://registry.terraform.io/providers/hashicorp/kubernetes/2.4/docs/resources/manifest) | resource |
| [kubernetes_manifest.karpenter_node_pool_1](https://registry.terraform.io/providers/hashicorp/kubernetes/2.4/docs/resources/manifest) | resource |
| [kubernetes_service.springboot](https://registry.terraform.io/providers/hashicorp/kubernetes/2.4/docs/resources/service) | resource |
| [kubernetes_service_account.alb](https://registry.terraform.io/providers/hashicorp/kubernetes/2.4/docs/resources/service_account) | resource |
| [aws_ecrpublic_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/5.89.0/docs/data-sources/ecrpublic_authorization_token) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | `"eks"` | no |
| <a name="input_ecr_registry"></a> [ecr\_registry](#input\_ecr\_registry) | n/a | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

# 2. 코드 및 구조 설계
1. 테라폼 tf 파일은 자원별로 분리하여 관리에 편하도록 작성하였습니다.
2. 잘모르는 상태에서 더 많은 자원 혹은 옵션을 추가할 경우 비용 낭비 및 예상치 못한 에러 상황을 만드는 계기가 되기 때문에 시나리오 외 불필요한 옵션은 추가하지 않았습니다.
3. 협업 및 인수인계 시 가독성 증대를 위해 공식 DOCS 및 가이드의 예시 구조를 최대한 살리고자 노력하였습니다.
4. 변수명에 terraform.workespace 를 사용하여 환경별로 분리하여 사용할 수 있습니다.

## 1. provider.tf
1. provider 의 경우 aws, kubernetes, terraform, helm 버전을 지정하였으며 Backend를 사용할 경우 tfstate의 S3 저장 후 공동 작업, 충돌 방지 기능을 사용할 수 있도록 작성하였습니다.

## 2. vpc.tf
1. 시나리오 요구사항에 맞춰 2개의 AZ를 사용했으며 각 2개의 Public, Private Subnet을 생성하였으며 서브넷에는 AWS ELB, Karpenter 가 사용될 서브넷임을 지정하는 태그를 추가하였습니다.
2. NAT 게이트웨이의 IP를 고정 하기 위해서 EIP를 직접 생성하여 지정해줄 수 있습니다.(선택)
3. 각 AZ 마다 NAT 사용 Private Subnet에서 외부 통신 시 같은 Zone의 NAT를 이용하는 조건을 충족시키기 위해 3개의 옵션을 설정하였습니다.
```terraform
  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true
```

## 3. eks.tf

## 4. karpenter.tf(선택)
1. 보통 태그를 사용하여 걸리는 서브넷 중 IP 여분이 많은 곳에 생성하지만 각 서브넷 ID를 지정해서 서브넷당 한개씩 노드그룹을 생성해보는 로직을 처음진행해 보았습니다.

## 5. deployment.tf
1. 안정성을 위해 readiness, liveness 프로브 2개를 설정하였습니다.(선택)
2. 이미지 교체 및 재실행 시 새로 생성되는 ALB 타겟그룹의 최소 헬스체크 성공 시간을 기존에 존재하는 타겟그룹들이 버텨주기위해 prestop sleep 을 추가하였습니다.(선택)
3. 디플로이먼트의 파드의 경우 각 노드마다 1개씩 각각 POD가 배치되어야 한다는 시나리오 요구사항이 존재하지않아 레이블을 통한 노드 배치 이외에 추가 로직은 작성하지 않았습니다.

## 6. service.tf
1. port, target port 모두 동일하게 8080를 사용하는 Cluster IP 기본 서비스를 생성하였으며 EKS의 vpc-cni Add on, ALB Target-type IP 모드를 사용할 경우 충분히 외부 노출이 가능합니다. 

## 7. alb.tf
1. EKS 쿠버네티스의 서비스 및 인그레스와의 직적 연동을 위해 ALB Controller를 Helm 으로 설치하여 사용하며 이또한 전부 Terraform 자원으로 설계하였습니다.
2. 

## 8. ingress.tf
1. http 접근 시 https로 리다이렉트를 위한 어노테이션을 추가하였습니다.
2. 타겟 모드 IP를 설정하였습니다.
3. 이미지 업데이트, 재배포, 노드 변경 등의 이유로 타겟 그룹에 대한 변경 시 빠른 헬스체크 성공을 위해 타겟 그룹의 경로 지정 및 체크 주기를 최소값으로 지정하였습니다.

## 9. docker, githubActions


# 참고
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/lbc-helm.html
https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/
