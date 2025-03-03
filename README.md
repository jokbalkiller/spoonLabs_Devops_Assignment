# Terraform 
# provider.tf
# vpc.tf
## 1. Subnet
구조도에 나온 것 처럼 2개의 AZ를 사용했으며 각 2개의 Public, Private Subnet을 생성하였습니다.
## 2. NatGateway
### 1. 고정 IP를 위한 EIP(선택)
NAT 게이트웨이를 고정 하기 위해서는 EIP를 직접 생성하여 지정해줄 수 있습니다.
### 2. 1개의 NAT 사용
Private Subnet에서 외부 통신 시 같은 Zone의 NAT를 이용하는 조건을 충족시키기 위해 3개의 옵션을 설정하였습니다. 가장 첫번째로 선언한 Public Subnet(10.21.0.0/24)에 Nat Gateway가 생성되게 됩니다. 
```terraform
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
```

# 설계 포인트
1. 최대한 간결하게 작성하려 노력했습니다. 
잘모르는 상태에서 더 많은 자원을 넣거나 옵션을 넣을 경우 비용 낭비 및 예상치 못한 에러 상황을 만드는 계기가 됩니다.
2. 공식 가이드 문서의 규격을 최대한 유지하려 노력했음
3. 

# 참고
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/lbc-helm.html
https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/
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