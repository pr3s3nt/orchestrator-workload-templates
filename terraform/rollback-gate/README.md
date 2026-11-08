# Issue 49 controlled Plan failure

Private acceptance fixture for pr3s3nt/poc issue 49. No external provider, provisioner,
cloud resource or Kubernetes resource is configured. With permit=false, Terraform
Plan fails on a resource precondition before Apply. The platform should retain the
failed deployment diagnostic and allow whole-Environment rollback to its successful
checkpoint. The fixture branch does not change existing template/module tags.
