import hashlib
from robot.libraries.BuiltIn import BuiltIn


def split_data(raw_data):
    client_id = raw_data.split('Client ID: ')
    client_id = client_id[1].split("\n")[0]

    client_name= raw_data.split("Client Name:")[1]
    client_name = client_name.split("\n")[0]

    client_country = raw_data.split("Client Country:")[1]
    client_country = client_country.split("\n")[0]
    #BuiltIn().log_to_console(client_country)

    return [client_id, client_name, client_country]

def create_client_hash(hash_data):
    
    data = bytes(hash_data,'utf-8')
    return hashlib.sha224(data).hexdigest()
    

