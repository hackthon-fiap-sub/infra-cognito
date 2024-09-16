import hmac
import hashlib
import base64

def calculate_secret_hash(client_id, client_secret, username):
    message = username + client_id
    dig = hmac.new(str(client_secret).encode('utf-8'), 
                   msg=str(message).encode('utf-8'),
                   digestmod=hashlib.sha256).digest()
    secret_hash = base64.b64encode(dig).decode()
    return secret_hash

# Substitua pelos valores corretos
client_id = '3et982rlhtr6p9nfcp0ugh9eik'
client_secret = 'qeue3ukhpl8m9qgeovt3k8i2cqos6o1t4qs36r3tdhke27o1lmb'
username = 'heitor.bittencourt.azevedo@selectgearmotors.com.br'

# Gerar o SECRET_HASH
secret_hash = calculate_secret_hash(client_id, client_secret, username)
print("SECRET_HASH:", secret_hash)
