# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DOCKER ?= docker
# Image to build protobufs
PROTO_IMG ?= k8s.gcr.io/kube-cross:v1.13.6-1
# The controller-gen command for generating CRDs from API definitions.
CONTROLLER_GEN=GOFLAGS=-mod=vendor go run sigs.k8s.io/controller-tools/cmd/controller-gen
# The output directory for generated CRDs.
CRD_OUTPUT_DIR ?= "config/crd/bases"
# Produce CRDs that work back to Kubernetes 1.11 (no version conversion)
CRD_OPTIONS ?= "crd:crdVersions=v1"
# TOP is the current directory where this Makefile lives.
TOP := $(dir $(firstword $(MAKEFILE_LIST)))
# ROOT is the root of the mkdocs tree.
ROOT := $(abspath $(TOP))

all: controller generate verify

# Kubebuilder driven custom resource definitions.
.PHONY: controller
controller:
	make -f kubebuilder.mk

# Run generators for protos, Deepcopy funcs, CRDs, and docs..
.PHONY: generate
generate:
	$(MAKE) proto
	$(MAKE) -f kubebuilder.mk generate
	$(MAKE) manifests
	$(MAKE) docs

# Build the documentation.
.PHONY: docs
docs:
	make -f docs.mk

# Serve the docs site locally at http://localhost:8000.
.PHONY: serve
serve:
	make -f docs.mk serve

.PHONY: clean
clean:
	make -f docs.mk clean

# Generate manifests e.g. CRD, RBAC etc.
.PHONY: manifests
manifests:
	$(CONTROLLER_GEN) $(CRD_OPTIONS) rbac:roleName=manager-role webhook paths="./..." output:crd:artifacts:config=$(CRD_OUTPUT_DIR)

# Generate protobufs
.PHONY: proto
proto:
	$(DOCKER) run -it \
		--mount type=bind,source=$(ROOT),target=/go/src/github.com/vmware-tanzu/service-apis  \
		--mount type=bind,source=$(GOPATH)/pkg/mod,target=/go/pkg/mod  \
		--env GOPATH=/go \
		--env GOCACHE=/go/.cache \
		--rm \
		--user "$(shell id -u):$(shell id -g)" \
		-w /go/src/github.com/vmware-tanzu/service-apis \
		$(PROTO_IMG) \
		hack/update-proto.sh

# Verify protobuf generation
.PHONY: verify-proto
verify-proto:
	$(DOCKER) run \
		--mount type=bind,source=$(ROOT),target=/realgo/src/github.com/vmware-tanzu/service-apis \
		--mount type=bind,source=$(GOPATH)/pkg/mod,target=/go/pkg/mod  \
		--env GOPATH=/go \
		--env GOCACHE=/go/.cache \
		--rm \
		--user "$(shell id -u):$(shell id -g)" \
		-w /go \
		$(PROTO_IMG) \
		/bin/bash -c "mkdir -p src/github.com/vmware-tanzu/service-apis && \
			cp -r /realgo/src/github.com/vmware-tanzu/service-apis/ src/github.com/vmware-tanzu && \
			cd src/github.com/vmware-tanzu/service-apis && \
			hack/update-proto.sh && \
			diff -r apis /realgo/src/github.com/vmware-tanzu/service-apis/api"

# Install the CRD's and example resources to a pre-existing cluster.
.PHONY: install
install: crd example

# Install the CRD's to a pre-existing cluster.
.PHONY: crd
crd:
	make -f kubebuilder.mk install

# Install the example resources to a pre-existing cluster.
.PHONY: example
example:
	hack/install-examples.sh

# Remove installed CRD's and CR's.
.PHONY: uninstall
uninstall:
	hack/delete-crds.sh

# Run static analysis.
.PHONY: verify
verify:
	hack/verify-all.sh
