resource "aws_resourcegroups_group" "project" {
  name        = "${local.name_prefix}-resources"
  description = "Resources tagged for ${local.name_prefix}."

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Project"
          Values = [var.project_name]
        },
        {
          Key    = "Environment"
          Values = [var.environment]
        }
      ]
    })
    type = "TAG_FILTERS_1_0"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-resources"
  })
}
