resource "aws_iam_group" "platform" {
  name = "${var.name_prefix}-platform"
}

resource "aws_iam_group" "read_only" {
  name = "${var.name_prefix}-read-only"
}

resource "aws_iam_user" "this" {
  for_each = var.iam_users

  name = lower(replace(each.key, " ", "-"))
  path = each.value.path
  tags = merge(var.tags, {
    Name       = lower(replace(each.key, " ", "-"))
    Department = each.value.department
  })
}

resource "aws_iam_group_membership" "platform" {
  count = length([for _, user in var.iam_users : user if user.department == "platform"]) > 0 ? 1 : 0

  name  = "${var.name_prefix}-platform-membership"
  group = aws_iam_group.platform.name
  users = [for user in aws_iam_user.this : user.name if user.tags.Department == "platform"]
}

resource "aws_iam_group_policy_attachment" "read_only" {
  group      = aws_iam_group.read_only.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
