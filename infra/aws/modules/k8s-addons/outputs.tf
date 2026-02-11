output "release_name" {
  value = length(helm_release.this) > 0 ? helm_release.this[0].name : null
}

output "namespace" {
  value = length(helm_release.this) > 0 ? helm_release.this[0].namespace : null
}

output "chart" {
  value = length(helm_release.this) > 0 ? helm_release.this[0].chart : null
}

output "version" {
  value = length(helm_release.this) > 0 ? helm_release.this[0].version : null
}

output "status" {
  value = length(helm_release.this) > 0 ? helm_release.this[0].status : null
}

output "revision" {
  value = length(helm_release.this) > 0 ? helm_release.this[0].version : null
}

output "values" {
  value     = length(helm_release.this) > 0 ? helm_release.this[0].values : null
  sensitive = true
}