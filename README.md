# Kubernetes Service/Ingress API evolution

---

**Note**: Please refrain from using this project. Instead, please refer to the [upstream repository](https://github.com/kubernetes-sigs/service-apis). Thank you!

---

This project is a fork of the upstream, [Kubernetes Service APIs](https://github.com/kubernetes-sigs/service-apis) project for the sole purpose of the [`support/pacific`](https://github.com/vmware-tanzu/service-apis/tree/support/pacific) branch that defines the following schema versions for the Service APIs:

| Schema Version | Commit | Package |
|---|---|---|
| `v1alpha0` | [917c67fb9089](https://github.com/kubernetes-sigs/service-apis/commit/917c67fb9089) | `github.com/vmware-tanzu/service-apis/api/v1alpha0` |
| `v1alpha1pre1` | [11f91778099d](https://github.com/kubernetes-sigs/service-apis/commit/11f91778099d) | `github.com/vmware-tanzu/service-apis/api/v1alpha1pre1` |

## Supporting `v1alpha0` and `v1alpha1pre1`

While it is possible to use the `support/pacific` branch to have access to Go types that support both schemas, the CRDs themselves are a different story.

An older version of `TcpRoute` is incompatible with newer versions of `TCPRoute`. The two names use different casing, and a Kubernetes CRD's `Kind` field is:

* Case insensitive
* Immutable between versions

Since the original `TcpRoute` was a skeleton type anyway, and not used for anything, this just means that in preparation to applying the new CRDs, the following command must be executed against the cluster against which the CRDs are to be applied:

```shell
kubectl delete CustomResourceDefinition tcproutes.networking.x-k8s.io
```

This will remove the `v1alpha0` version of the `TcpRoute` and safely allow the new `TCPRoute` CRD to be installed.

Again, this is not an issue because the older `TcpRoute` is:

* A skeleton type without any real fields
* Not used or implemented by anyone

## Creating the Support Branch

This section describes how the support branch was created for schema versions `v1alpha0` and `v1alpha1pre1`:

## v1alpha0

The `v1alpha0` schema was created by:

1. Creating a branch from the upstream repository at commit [917c67fb9089](https://github.com/kubernetes-sigs/service-apis/commit/917c67fb9089)
2. Finding and replacing all instances of `v1alpha1` with `v1alpha0`
3. Renaming the Go module from `sigs.k8s.io/service-apis` to `github.com/vmware-tanzu/service-apis`
4. Re-running the generator code to ensure all the protobufs were updated

These changes enable someone use the following resources at schema version `v1alpha0`:

* `gatewayclass.networking.x-k8s.io`
* `gateway.networking.x-k8s.io`
* `httproute.networking.x-k8s.io`
* `trafficsplit.networking.x-k8s.io`
* `tcproute.networking.x-k8s.io`

## v1alpha1pre1

The `v1alpha1pre1` schema was created by:

1. Renaming the `support/v1alpha0` branch to `support/pacific`:

    ```shell
    git branch -m support/v1alpha0 support/pacific
    ```

2. Creating a branch `temp1` at commit [11f91778099d](https://github.com/kubernetes-sigs/service-apis/commit/11f91778099d):

    ```shell
    git checkout -b temp1 11f91778099d6720ddc066ddcde327fa6216aec0
    ```

3. Reading just the desired directory, and the commits responsible for its contents, from commit the [11f91778099d](https://github.com/kubernetes-sigs/service-apis/commit/11f91778099d) into branch `temp2`:

    ```shell
    git subtree split --prefix=apis/v1alpha1 -b temp2
    ```

4. Checking out branch `support/pacific`:

    ```shell
    git checkout support/pacific
    ```

5. Reading the contents, and commtis responsible for the contents, from the split branch, `temp2`, into the `api/v1alpha1pre1` directory of the `support/pacific` branch:

    ```shell
    git subtree add --prefix=api/v1alpha1pre1 temp2
    ```

6. Finding and replacing all instances of `v1alpha1` with `v1alpha1pre1`

7. Re-running the generator code to ensure all the protobufs were updated

These changes enable someone use the following resources at schema version `v1alpha1pre1`:

* `gatewayclass.networking.x-k8s.io`
* `gateway.networking.x-k8s.io`
* `httproute.networking.x-k8s.io`
* `tcproute.networking.x-k8s.io`
