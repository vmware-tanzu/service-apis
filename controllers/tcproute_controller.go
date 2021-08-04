/*

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controllers

import (
	"context"

	"github.com/go-logr/logr"
	"github.com/vmware-tanzu/service-apis/api/v1alpha0"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

// TcpRouteReconciler reconciles a TcpRoute object
type TcpRouteReconciler struct {
	client.Client
	Log logr.Logger
}

// +kubebuilder:rbac:groups=networking.x-k8s.io,resources=tcproutes,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=networking.x-k8s.io,resources=tcproutes/status,verbs=get;update;patch

// Reconcile the changes.
func (r *TcpRouteReconciler) Reconcile(_ context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = r.Log.WithValues("tcproute", req.NamespacedName)

	// your logic here

	return ctrl.Result{}, nil
}

// SetupWithManager wires up the controller.
func (r *TcpRouteReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&v1alpha0.TcpRoute{}).
		Complete(r)
}
