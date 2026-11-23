resource "incus_image" "prometheus" {
  source_image = {
    remote = "docker"
    name   = "prom/prometheus:v3.16.0@sha256:e04987641b57704f408e31f6373ba4138ecf27cb4a165d24aabb6c38fddd0f06"
  }
}
