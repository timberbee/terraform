


provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
data "aws_iam_policy_document" "pc_ro" {
    statement {
        sid = "AllowPrismaCloudROExternalAccess"
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type = "AWS"
            identifiers = ["arn:aws:iam::188619942792:root"]
        }
        condition {
            test = "StringEquals"
            variable = "sts:ExternalId"
            values = ["${var.pc_ro_id}"]
        }
    }
}

resource "aws_iam_policy" "pc_ro_file" {
    name = "PrismaCloud_policy_RO"
    policy = "${file("aws_iam_policy_document_pc_ro.json")}"
}

resource "aws_iam_role" "pc_ro" {
    name = "${var.pc_ro_role_name}"
    assume_role_policy = "${data.aws_iam_policy_document.pc_ro.json}"
    description = "Read only role for Prisma Cloud"
}

resource "aws_iam_role_policy_attachment" "rl_secaudit_pol_attach" {
    role = "${aws_iam_role.rl_ro.name}"
    policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "rl_ro_file_attach" {
    role = "${aws_iam_role.rl_ro.name}"
    policy_arn = "${aws_iam_policy.rl_ro_file.arn}"
}
output "rl_role_output_ExtID" {
    value = "${var.rl_ro_id}"
}
