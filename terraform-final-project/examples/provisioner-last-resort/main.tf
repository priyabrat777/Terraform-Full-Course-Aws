terraform {
  required_version = ">= 1.6.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

resource "null_resource" "documented_last_resort" {
  triggers = {
    explanation = "Provisioners are intentionally isolated from the production path."
  }

  provisioner "local-exec" {
    command = "echo Provisioners should be reserved for cases where no provider-native resource exists."
  }
}
