resource "aws_ram_resource_share" "ram-shared" {
  name                      = var.ram_name
  allow_external_principals = var.allow_external_principals
}

resource "aws_ram_principal_association" "tgw-ram-principal-shared" {
  principal          = var.ram_principals
  resource_share_arn = aws_ram_resource_share.ram-shared.arn
}
