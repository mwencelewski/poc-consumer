*** Keywords ***

Login
    
    Open Browser  https://acme-test.uipath.com/login  browser=chromium  headless=False   
    Set Browser Timeout   30
    Wait For Elements State  ${login_page.header}    visible
    Get Text   ${login_page.header}   contains   Login
    Fill Text   ${login_page.user}     mauro.wencelewski@primecontrol.com.br
    Fill Text   ${login_page.pwd}     ${password}
    #Fill Text   ${login_page.pass}     
    Click   ${login_page.submit}
    Wait For Elements State  ${dashboard.header}     visible

Navigate to Work Items

    Get Text    ${dashboard.header}  contains   Dashboard
    Click   ${dashboard.work_items}
    Wait For Elements State  ${work_items.header}       visible
    
    ${qty_pages}  Get Number of Pages to Extract
    ${qty_pages}  Evaluate  ${qty_pages}+1 
    
    [Return]  ${qty_pages}

Loop Through Items Pages
    [Arguments]     ${qty_pages}

    FOR    ${i}    IN RANGE    1    ${qty_pages}
            Loop Lines     
            Run Keyword If  ${i} != 1   Go To   https://acme-test.uipath.com/work-items?page=${i}
    END

Loop Lines

    ${lines}  Get Number of Lines in table
    FOR    ${x}    IN RANGE    1    ${lines}
            Loop Elements in Lines  ${x}
    END     

Loop Elements in Lines
    
    [Arguments]    ${current_line}
    ${current_line}  Evaluate  ${current_line}+1  
    
    ${wiid}  Format String  ${work_items.wiid}  line=${current_line}
    ${wiid}  Get Text  ${wiid}
    
    ${description}  Format String  ${work_items.description}  line=${current_line}
    ${description}  Get Text  ${description}

    ${type}   Format String   ${work_items.type}    line=${current_line}
    ${type}   Get Text  ${type}


    Create Transaction  POC-Producer/Consumer   V1     ${wiid}     ${type}
    
    #Log To Console  ${wiid} - ${description} - ${type}
    
    # Run Keyword If  '${type}' == 'WI5'  Run Keywords
    # ...         Go To  https://acme-test.uipath.com/work-items/${wiid}
    # ...         AND  Security Hash Creation Workflow
    # ...         ELSE    Insert Atencao Operacional  ${execution_ID}   V1   ${now}   ${wiid}    ${type}   Tipo de Pedido Inválido

Security Hash Creation Workflow
    
    Extract Client Information
    @{client_data}   Split Data  ${client_full_data}
    
    ${client_id}  Get From List  ${client_data}  0
    ${client_name}  Get From List  ${client_data}  1
    ${client_country}  Get From List  ${client_data}  2

    ${hash_data}  Catenate  ${client_id}  ${client_name}  ${client_country}  SEPARATOR=-
 
    ${security_hash}    Create Client Hash   ${hash_data}
    Insert Controle Operacional  ${execution_ID}  ${transaction_ID}  V1   ${client_id}  ${client_name}  ${client_country}  ${security_hash}
 
Extract Client Information

    Wait For Elements State     ${work_items.header}     visible
    Get Text  ${work_items.header}   contains       Work Items - Work Item Details
    
    ${client_full_data}   Get Text  ${client_information.client_full_data}
    
    Set Global Variable  ${client_full_data} 
    Go Back
 
Get Number of Lines in table
    ${line_count}  Get Element Count   ${work_items.table_row}
    [Return]    ${line_count}

Get List of Elements in table
    @{elem}  Get Elements  ${work_items.table_row}
    [Return]   @{elem}

Get Number of Pages to Extract
    ${qty_of_pages}     Get Element Count   ${work_items.page_qty}
    #Log To Console  ${qty_of_pages}
    ${qty_of_pages}  Evaluate  ${qty_of_pages}-1
    [Return]   ${qty_of_pages}

