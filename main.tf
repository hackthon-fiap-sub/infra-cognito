provider "aws" {
  region = "us-east-1"  # Replace with your preferred AWS region
}

# Variáveis
variable "user_pools" {
  type = map(object({
    name         = string
    client_name  = string
    callback_urls = list(string)
  }))
  default = {
    "selectgearmotors" = {
      name         = "selectgearmotors-user-pool"
      client_name  = "selectgearmotors-app-client"
      callback_urls = ["https://selectgearmotors.com.br/callback"]
    }
  }
}

# Criando múltiplos user pools
resource "aws_cognito_user_pool" "user_pool" {
  for_each = var.user_pools

  name                   = each.value.name
  auto_verified_attributes = ["email"]
  //username_attributes    = ["email"]
  alias_attributes = ["preferred_username"]

  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}."
      email_subject = "Your temporary password"
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }

  deletion_protection = "INACTIVE"
  mfa_configuration   = "OFF"

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true 
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  schema {
    name                = "preferred_username"
    attribute_data_type = "String"
    required            = false
  }

  schema {
    name                = "cpf"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  schema {
    name                = "id"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  username_configuration {
    case_sensitive = false
  }

}

#resource "aws_cognito_user_pool_domain" "cognito_domain" {
 # domain        = "selectgearmotors"  # Substitua pelo prefixo do seu domínio
  #user_pool_id  = aws_cognito_user_pool.user_pool["selectgearmotors"].id
#}

# Criando múltiplos user pool clients
resource "aws_cognito_user_pool_client" "user_pool_client" {
  for_each = var.user_pools

  name                          = each.value.client_name
  user_pool_id                  = aws_cognito_user_pool.user_pool[each.key].id
  allowed_oauth_flows           = ["code", "implicit"]
  allowed_oauth_scopes          = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  callback_urls                 = each.value.callback_urls
  allowed_oauth_flows_user_pool_client = true
  explicit_auth_flows           = ["ALLOW_USER_PASSWORD_AUTH","ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_ADMIN_USER_PASSWORD_AUTH"]
  generate_secret               = true
}

# Criando múltiplos user groups
resource "aws_cognito_user_group" "user_group" {
  for_each = var.user_pools

  name        = each.value.client_name
  user_pool_id = aws_cognito_user_pool.user_pool[each.key].id
  description = "User group for ${each.value.client_name}"
}

################################################################################
# Grupos
################################################################################

resource "aws_cognito_user_group" "admins" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.user_pool["selectgearmotors"].id
  description  = "Administradores da Select Gear Motors"
}

resource "aws_cognito_user_group" "users" {
  name         = "user"
  user_pool_id = aws_cognito_user_pool.user_pool["selectgearmotors"].id
  description  = "Usuarios da Select Gear Motors"
}

################################################################################
# Users
################################################################################

# admins
# ------------------------------

resource "aws_cognito_user" "admin_1" {
  user_pool_id = aws_cognito_user_pool.user_pool["selectgearmotors"].id
  username     = "anna.galindo.rodrigues@selectgearmotors.com.br" # email 
  password     = "Admin@123"

  attributes = {
    id = "ff05d25e-8027-473e-afd7-a0ec59dc571c"
    name        = "Anna Galindo Rodrigues"
    email       = "anna.galindo.rodrigues@selectgearmotors.com.br"
    preferred_username = "anna.galindo.rodrigues@selectgearmotors.com.br"
  }
}

resource "aws_cognito_user_in_group" "admin_1" {
  user_pool_id = aws_cognito_user_pool.user_pool["selectgearmotors"].id
  group_name   = aws_cognito_user_group.admins.name
  username     = aws_cognito_user.admin_1.username
}

# ----------

resource "aws_cognito_user" "admin_2" {
  user_pool_id = aws_cognito_user_pool.user_pool["selectgearmotors"].id
  username     = "heitor.bittencourt.azevedo@selectgearmotors.com.br" # email 
  password     = "Admin@123"

  attributes = {
    id = "70d57e1a-30b2-407d-a75c-8ff7643c8460"
    name        = "Heitor Bittencourt de Azevedo"
    email       = "heitor.bittencourt.azevedo@selectgearmotors.com.br"
    preferred_username = "heitor.bittencourt.azevedo@selectgearmotors.com.br"
  }
}

resource "aws_cognito_user_in_group" "admin_2" {
  user_pool_id = aws_cognito_user_pool.user_pool["selectgearmotors"].id
  group_name   = aws_cognito_user_group.admins.name
  username     = aws_cognito_user.admin_2.username
}

# Pacientes
# ------------------------------

resource "aws_cognito_user" "user_1" {
  user_pool_id = aws_cognito_user_pool.user_pool["selectgearmotors"].id
  username     = "ketlin.silvana.aragao.torres@gmail.com" # CPF
  password     = "Mudar@123"

  attributes = {
    id = "1e8352d3-8c13-4cdc-b044-8e266c5f5154"
    name  = "Ketlin Silvana Aragão de Torres"
    email = "ketlin.silvana.aragao.torres@gmail.com"
    cpf = "12345678900"
    preferred_username = "ketlin.silvana.aragao.torres@gmail.com"
  }
}

resource "aws_cognito_user_in_group" "user_1" {
  user_pool_id = aws_cognito_user_pool.user_pool["selectgearmotors"].id
  group_name   = aws_cognito_user_group.users.name
  username     = aws_cognito_user.user_1.username
}