*** Settings ***

Resource    ${ROOT}/Resource/main.Resource
Suite Setup      Setup ACME
Suite Teardown      Teardown ACME

*** Variables ***

${password}=  prime123


*** Test Cases ***

ACME Consumer main

    Login 
    FOR    ${i}    IN RANGE    999999
        ${transaction}  Get Transaction From Queue
        Exit For Loop If  "${transaction}" == "None"
        Set Test Variable   ${transaction}
        Check Transaction Data 
    END    

*** Keywords ***

Get Transaction From Queue
    ${transaction}  Get Transaction   ${execution_ID}  POC-Producer/Consumer    V1
    ${hora_atual}   Get Current Date  time_zone=local  increment=0  result_format=timestamp  exclude_millis=False
    Log To Console  Transação consumida ${transaction} ${hora_atual}
    [Return]  ${transaction}
    
Check Transaction Data

    
    ${dictionary_with_data}  Get From List  ${transaction}  0
    ${modified_transactions}  Get From List  ${transaction}  1
    ${dictionary_with_data}   Get From List  ${dictionary_with_data}  0
    ${wiid_type}  Get From Dictionary  ${dictionary_with_data}  type
    ${transaction_ID}  Get From Dictionary  ${dictionary_with_data}  _id
    ${wiid_number}  Get From Dictionary  ${dictionary_with_data}  wiid_number

    Set Test Variable  ${wiid_type}
    Set Test Variable  ${transaction_ID}
    Set Test Variable  ${wiid_number}  

    #Log To console  ${wiid_type}
    Run Keyword If  '${wiid_type}' != 'WI5'  Set Transaction As Business Exception  ${transaction_ID}
    ...        ELSE     Create Security Hash 


Create Security Hash
    

    Go To  https://acme-test.uipath.com/work-items/${wiid_number}
    ${status}  Run Keyword And Return Status   Security Hash Creation Workflow
    Run Keyword If  ${status}   Set Transaction As Success
    ...       ELSE  Set Transactions as Failure


Set Transaction As Success
   
    Log To Console  Setando transação ${transaction_ID} como sucesso.
    Set As Success  ${transaction_ID}

Set Transaction as Failure

    Log to Console  Setando transação ${transaction_ID} como falha.
    Set As Failure  ${transaction_ID}  Falha inesperada ocorreu.

Set Transaction As Business Exception
    [Arguments]  ${transaction_ID}

    Log To Console  Setando transação ${transaction_ID} como exceção de negócio.
    ${status}  Set As Be  ${transaction_ID}  WID Inválido
    Insert Atencao Operacional  ${execution_ID}  ${transaction_ID}   V1    ${wiid_number}    ${wiid_type}  WID Inválido     
