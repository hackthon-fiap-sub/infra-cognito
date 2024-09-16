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
client_id = '3u9l5ieeoemksbvcjpfkpn12i8'
client_secret = '1sjf91lg6a36l0te9ngsc8clkd7qcnelg8cc5pfrpeleoqdmrf61'
username = 'heitor.bittencourt.azevedo@selectgearmotors.com.br'

# Gerar o SECRET_HASH
secret_hash = calculate_secret_hash(client_id, client_secret, username)
print("SECRET_HASH:", secret_hash)
