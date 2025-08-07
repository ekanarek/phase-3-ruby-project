# Personal Shopping Tracker

Uses a Sinatra API backend with Active Record and a Ruby CLI frontend.

## Domain Model

A simple application to manage shopping receipts and purchased items.

- `Store` has many `Receipts` and many `Items`
- `Receipt` belongs to `Store` and has many `Items`
- `Item` belongs to `Receipt` and belongs to `Store`

### Models

#### Store

- `name` (string)

#### Receipt

- `date` (string)
- `store_id` (integer)

#### Item

- `name` (string)
- `price` (integer)
- `receipt_id` (integer)
- `store_id` (integer)

## Backend API

### Routes

#### Receipts (Full CRUD)

- `GET /receipts` - List all receipts with their items and store
- `GET /receipts/:id` - Get a specific receipt with its items and store
- `POST /receipts` - Create a new receipt and its associated items
- `PATCH /receipts/:id` - Update a receipt
- `DELETE /receipts/:id` - Delete a receipt and its associated items

#### Items (Full CRUD)

- `GET /items` - List all items with their store and receipt
- `GET /items/:id` - Get a specific item
- `POST /items` - Create a new item associated with an existing receipt
- `PATCH /items/:id` - Update an item
- `DELETE /items/:id` - Delete an item
