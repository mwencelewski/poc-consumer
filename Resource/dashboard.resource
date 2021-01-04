*** Variables ***

&{dashboard}        work_items=xpath=//button[text()=' Work Items']
...                 header=xpath=//h1[contains(.,'Dashboard')]



&{work_items}       header=xpath=//h1
...                 table_row=xpath=//table//tr
...                 page_qty=xpath=//a[@class='page-numbers' or @class='page-numbers current']
...                 wiid=xpath=//table//tr[{line}]//td[2]
...                 description=xpath=//table//tr[{line}]//td[3]
...                 type=xpath=//table//tr[{line}]//td[4]
...                 status=xpath=//table//tr[{line}]//td[5]
...                 date=xpath=//table//tr[{line}]//td[6]


&{client_information}       client_data=xpath=//div[@class='main-container']//h4[contains(.,'Client Information Details')]//following::b[contains(.,"{field}")]//following-sibling::text()[1]
...                         client_full_data=xpath=//h4[contains(.,'Client Information Details')]//following::p[1]

#//following::text()[1]
                        