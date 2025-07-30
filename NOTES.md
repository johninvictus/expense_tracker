## Explain your approach to handling money/currency
I am using Money library that uses Decimal for calculations, I decided to default to USD for now to avoid doing alot complex code.

## Describe any architectural decisions you made
1. I used Ecto for database and Phoenix for the web interface
2. I used Money library for handling money/currency
3. I used Phoenix LiveView for the web interface
4.I did not touch budget table when manupulating transactions, in order to have better performance, and also to avoid locking the table when doing concurrent transactions

5. Instead of resetting the budget limit when creating a transaction, I choose not to manupulate it but use it as a hard limit for each month

## Note any trade-offs or shortcuts taken due to time constraints
1. I did not implement the funding logic but I put the fields necessary for it
2. In a production application I would have added a read and write replica
3. In production I would have created a ledger system for transactions in order to maintain better records

## Explain your testing strategy
1. I used unit test mostly
2. I avoided seed data as much as possible
3. I tested liveviews
4. github actions for ci




