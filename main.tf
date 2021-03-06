data "kustomization_overlay" "resources" {
  resources = [
    "${path.module}/all"
  ]
  patches {
    target = {
      kind = "Ingress"
      name = "docker-debug"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/rules/0/host
      value: docker-debug.${var.domain}
    - op: replace
      path: /spec/tls/0/hosts/0
      value: docker-debug.${var.domain}
    EOF
  }

}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = data.kustomization_overlay.resources.ids_prio[0]
  manifest = data.kustomization_overlay.resources.manifests[each.value]
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
resource "kustomization_resource" "p1" {
  for_each   = data.kustomization_overlay.resources.ids_prio[1]
  manifest   = data.kustomization_overlay.resources.manifests[each.value]
  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each   = data.kustomization_overlay.resources.ids_prio[2]
  manifest   = data.kustomization_overlay.resources.manifests[each.value]
  depends_on = [kustomization_resource.p1]
}
