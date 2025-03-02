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