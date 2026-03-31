locals {
  
  helm_values = {
    admissionController  = { replicas = 1 }
    backgroundController = { replicas = 1 }
    cleanupController    = { replicas = 1 }
    reportsController    = { replicas = 1 }

    # This block ensures the jobs are recreated AND use the right image
    cleanupJobs = {
      enabled = true
      kubectl = {
        image = {
          registry   = "registry.k8s.io/kubectl"
          repository = "kubectl"
          tag        = "v1.32.0"
        }
      }
    }
  }
  
}