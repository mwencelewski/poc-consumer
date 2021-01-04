*** Settings ***

Library     Browser
Library     String
Library     Collections
Library     OperatingSystem
Library     DateTime



Resource    ${ROOT}/Resource/login.resource
Resource    ${ROOT}/Resource/dashboard.resource
Resource    ${ROOT}/Modules/acme-system.robot
Resource    ${ROOT}/Modules/setup_and_teardown.robot


Library     ${ROOT}/Library/create_hash.py
Library     ${ROOT}/Library/mongo.py