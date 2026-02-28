build {
  name    = "golden-image"
  sources = ["source.amazon-ebs.al2023"]

  provisioner "shell" {
    script          = "../scripts/01_system_patching.sh"
    execute_command = "sudo bash -ex '{{.Path}}'"
  }

  provisioner "shell" {
    script          = "../scripts/02_ssh_hardening.sh"
    execute_command = "sudo bash -ex '{{.Path}}'"
  }

  provisioner "shell" {
    script          = "../scripts/03_hardening.sh"
    execute_command = "sudo bash -ex '{{.Path}}'"
  }

  provisioner "shell" {
    execute_command = "sudo bash -ex '{{.Path}}'"
    inline = [
      "echo '==> [04] Lynis security audit'",
      "lynis audit system --quick --no-colors 2>&1 | tee /tmp/lynis-report.txt",
      "SCORE=$(grep 'Hardening index' /tmp/lynis-report.txt | awk -F'[][]' '{print $2}')",
      "echo \"Lynis hardening score: $SCORE\"",
      "[ \"$SCORE\" -ge 70 ] || (echo 'ERROR: Lynis score below minimum threshold of 70' && exit 1)",
      "echo '==> [04] Done: Lynis audit passed'"
    ]
  }

  # Cleanup
  provisioner "shell" {
    script          = "../scripts/99_cleanup.sh"
    execute_command = "sudo bash -ex '{{.Path}}'"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
