terragrunt = {

  include {
    path = "${find_in_parent_folders()}"
  }

  extra_arguments "conditional_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy"
    ]

    optional_var_files = [
      "${get_tfvars_dir()}/../global.tfvars",
      "${get_tfvars_dir()}/custom.tfvars",
    ]
  }
}
