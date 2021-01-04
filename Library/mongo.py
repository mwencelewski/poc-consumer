from pymongo import MongoClient
from datetime import datetime
from bson.objectid import ObjectId
import json
#import pandas as pd

client = MongoClient("mongodb+srv://mwencele:prime123@sandbox.3cyt8.mongodb.net/rpa-execution?retryWrites=true&w=majority&ssl=true&ssl_cert_reqs=CERT_NONE")
db = client['rpa-execution']
collection = db['jobs']
data_inicio = datetime.now()

def create_transaction(process_name, schema_version, wiid_number, wiid_type):
    creation_date = datetime.now()
    collection = db["rpa-transactions"]
    transaction = {
        "process_name":process_name,
        "schema_version": schema_version,
        "creation_date": creation_date,
        "wiid_number": wiid_number,
        "type": wiid_type,
        "status":"novo"
    }
    status = collection.insert_one(transaction).inserted_id
    return status

def get_transaction(execution_id, process_name,schema_version):
    collection = db["rpa-transactions"]
    query = collection.aggregate([
        {
            "$match": {
                "process_name": process_name,
                "schema_version": schema_version,
                "status": "novo",
                "consumer_id":""
            }
        },
        {
            "$limit":1
        },
        {
            "$project":{
                "wiid_number":1,
                "type":1
            }
        }
    ])
    
    query = list(query)
    if len(query) > 0:
        #atualiza status da transacao
        update = collection.update_one(
            {"_id": ObjectId(query[0]['_id']),
            "status":"novo",
            "consumer_id":""},
            {"$set": {
                      "status": "em_andamento",
                      "consumer_id": execution_id
                     }
            }
        )
        #update = list(update)
        print(f"UPDATE {update.modified_count}")
        if update.modified_count == 1:
            return [query, update.modified_count]
        else:
            return None
        
        return query
    else: 
        return None   
    

def set_as_be(id,message):
    
    collection = db["rpa-transactions"]
    end_time = datetime.now()
    query = collection.update_one(
        {"_id":ObjectId(id)},
        {"$set": {
            "status":"Business Exception",
            "message":message,
            "end_time":end_time
        }}
    )    
    return query


def set_as_success(id):
    
    collection = db["rpa-transactions"]
    end_time = datetime.now()

    query = collection.update_one(
        {"_id":ObjectId(id)},
        {"$set": {
            "status":"Sucesso",
            "end_time":end_time
        }}
    )
    return query

def set_as_failure(id,message):
    
    collection = db["rpa-transactions"]
    end_time = datetime.now()

    query = collection.update_one(
        {"_id":ObjectId(id)},
        {"$set": {
            "status":"Falha",
            "message":message,
            "end_time":end_time
        }}
    )
    return query



def create_execution(process_name):
    execucao = {
          "process_name":process_name,
          "schema_version":"v1",
          "start_time": data_inicio,
          "end_time":"",
          "atencao_operacional":[],
          "controle_operacional":[],
          "metricas":[]
    }
    status = collection.insert_one(execucao).inserted_id
    return status

def end_execution(id):
    end_time = datetime.now()
    status = collection.update_one(
        {"_id": ObjectId(id)},
        {
            "$set":{"end_time":end_time}
        }
    )
    return status

def insert_controle_operacional(id, transaction_id, schema_version, client_id, client_name, client_country, client_hash):
    data = datetime.now()
    status = collection.update_one(
        {"_id": ObjectId(id)},
        { 
          "$push": {
              "controle_operacional": {
                  "schema_version": schema_version,
                  "transaction_id": transaction_id,
                  "data": data,
                  "client_id":client_id, 
                  "client_name": client_name,
                  "client_country": client_country,
                  "client_hash": client_hash
                  }
              }
        })
    return status

def insert_atencao_operacional(id, transaction_id, schema_version, wiid_number, wiid_type, message):
    data = datetime.now()
    status = collection.update_one(
      {"_id": ObjectId(id)},
      {
        "$push": {
            "atencao_operacional":{
                "transaction_id": ObjectId(transaction_id),
                "schema_version": schema_version,
                "data": data,
                "wiid_numberer": wiid_number,
                "type": wiid_type,
                "message": message
            }
        }
      }
    )
    return status

def extract_kpi(id):
    results = collection.aggregate(
        [
             {
                '$match': {
                    '_id': ObjectId(id)
                }
            },
            {
                '$project': {
                    '_id': 1, 
                    'process_name': 1, 
                    'schema_version': 1,
                    'start_time':1,
                    'end_time':1, 
                    'nao_criados': {
                        '$size': '$atencao_operacional'
                    }, 
                    'criados': {
                        '$size': '$controle_operacional'
                    },
                    'duracao':{
                        "$divide":[
                            {"$subtract": ["$end_time","$start_time"]},1000
                        ]
                    }
                }
            },{
                '$project': {
                    'process_name': 1, 
                    'schema_version': 1, 
                    'start_time': 1,
                    'end_time':1,
                    'nao_criados': 1, 
                    'criados': 1, 
                    'total': {
                        '$sum': [
                            '$nao_criados', '$criados'
                        ]
                    },
                    'duracao':1
                }
            }
        ]
    )    
    return list(results)

def insert_kpi(id,data):

    kpi = collection.update_one(
            {
                    "_id":ObjectId(id)
            },{
                "$set": {
                    "metricas":{
                        #
                        "process_name":data[0]["process_name"],
                        "schema_version":data[0]["schema_version"],
                        "start_time": data[0]["start_time"],
                        "end_time": data[0]["end_time"],
                        "criados": data[0]["criados"],
                        "nao_criados": data[0]["nao_criados"],
                        "duracao":data[0]["duracao"],
                        "total": data[0]["total"]
                    }
                }
            }
    )
    return kpi

