# customize the values below
TARGET_REGION ?= cn-northwest-1
AWS_PROFILE ?= default
KOPS_STATE_STORE ?= s3://pahud-kops-state-store-zhy
VPCID ?= vpc-bb3e99d2
MASTER_COUNT ?= 3
MASTER_SIZE ?= m4.large
NODE_SIZE ?= c5.large
NODE_COUNT ?= 2
SSH_PUBLIC_KEY ?= ~/.ssh/id_rsa.pub
KUBERNETES_VERSION ?= v1.11.9
KOPS_VERSION ?= 1.11.1

# do not modify following values
AWS_DEFAULT_REGION ?= $(TARGET_REGION)
AWS_REGION ?= $(AWS_DEFAULT_REGION)
ifeq ($(TARGET_REGION) ,cn-north-1)
	CLUSTER_NAME ?= cluster.bjs.k8s.local
	AMI ?= 	ami-01e99c7e0a343d325
	ZONES ?= cn-north-1a,cn-north-1b
endif

ifeq ($(TARGET_REGION) ,cn-northwest-1)
	CLUSTER_NAME ?= cluster.zhy.k8s.local
	AMI ?= ami-0773341917796083a
	ZONES ?= cn-northwest-1a,cn-northwest-1b,cn-northwest-1c
endif

KUBERNETES_VERSION_URI ?= "https://s3.cn-north-1.amazonaws.com.cn/kubernetes-release/release/$(KUBERNETES_VERSION)"


.PHONY: create-cluster
create-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops create cluster \
     --cloud=aws \
     --name=$(CLUSTER_NAME) \
     --image=$(AMI) \
     --zones=$(ZONES) \
     --master-count=$(MASTER_COUNT) \
     --master-size=$(MASTER_SIZE) \
     --master-volume-size=32 \
     --node-count=$(NODE_COUNT) \
     --node-size=$(NODE_SIZE)  \
     --node-volume-size=64 \
     --vpc=$(VPCID) \
     --kubernetes-version=$(KUBERNETES_VERSION_URI) \
     --networking=amazon-vpc-routed-eni \
     --ssh-public-key=$(SSH_PUBLIC_KEY)
     
.PHONY: edit-ig-nodes
edit-ig-nodes:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops edit ig --name=$(CLUSTER_NAME) nodes

.PHONY: edit-cluster
edit-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops edit cluster $(CLUSTER_NAME)
	
.PHONY: update-cluster
update-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops update cluster $(CLUSTER_NAME) --yes

.PHONY: validate-cluster
 validate-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops validate cluster
	
.PHONY: delete-cluster
 delete-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops delete cluster --name $(CLUSTER_NAME) --yes
	
.PHONY: rolling-update-cluster
rolling-update-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
        AWS_REGION=$(AWS_REGION) \
        AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
        kops rolling-update cluster --name $(CLUSTER_NAME) --yes --cloudonly


.PHONY: get-cluster
get-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
        AWS_PROFILE=$(AWS_PROFILE) \
        AWS_REGION=$(AWS_REGION) \
        AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
        kops get cluster --name $(CLUSTER_NAME)
