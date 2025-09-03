

resource "null_resource" "foo7" {
  depends_on = [google_compute_instance.aviController]
  connection {
    host        = google_compute_instance.jump.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    agent       = false
    user        = var.jump.username
    private_key = file(var.ssh_key.private)
  }

  provisioner "remote-exec" {
    inline      = [
    "git clone ${var.ansible.aviConfigureUrl} --branch ${var.ansible.aviConfigureTag} ; cd ${split("/", var.ansible.aviConfigureUrl)[4]} ; ansible-playbook gcp.yml --extra-vars @/home/ubuntu/controllerPrivateIp.yml --extra-vars '{\"avi_username\": ${jsonencode(var.avi_username)}, \"avi_password\": ${jsonencode(var.avi_password)}, \"avi_old_password\": ${jsonencode(var.avi_old_password)}, \"avi_version\": ${jsonencode(var.avi_version)}, \"gcpZones\": ${jsonencode(data.google_compute_zones.available.names)}, \"NetworkSeMgmt\": ${jsonencode(var.subnetworkName.0)}, \"gcp\": ${jsonencode(var.gcp)}, \"avi_servers_gcp\": ${jsonencode(google_compute_instance.backend.*.network_interface.0.network_ip)}}'",
    ]
  }
}
