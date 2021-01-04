*** Settings ***

Resource    ${ROOT}/Resource/main.resource


*** Keywords ***

Setup ACME
    Log To Console  Iniciando Processo  stream=STDOUT  no_newline=False
    ${now}      Get Current Date  time_zone=local  increment=0  result_format=timestamp  exclude_millis=True
    #${transaction}      Get Transaction  POC-Producer/Consumer    V1
    ${execution_ID}     Create Execution  POC-Consumer
    #Log To Console  ${execution_ID}
    Set Global Variable  ${execution_ID}
    #Log to Console  ${transaction}
    Set Global Variable  ${now}

Teardown ACME
    Log To Console  Processo Finalizado com Sucesso
    ${status}   End Execution  ${execution_ID}  
    ${kpi}  Extract Kpi  ${execution_ID}
    Insert Kpi  ${execution_ID}   ${kpi}
  