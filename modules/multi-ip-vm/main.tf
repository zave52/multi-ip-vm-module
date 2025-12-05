locals {
  ip_parts      = split(".", var.private_ip_start)
  ip_base       = "${local.ip_parts[0]}.${local.ip_parts[1]}.${local.ip_parts[2]}"
  ip_start_host = tonumber(local.ip_parts[3])

  total_ip_count = var.secondary_ip_count + 1

  private_ips = [
    for i in range(local.total_ip_count) :
    "${local.ip_base}.${local.ip_start_host + i}"
  ]
}
