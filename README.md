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

## Backend API Routes

### Receipts (Full CRUD)

- `GET /receipts` - List all receipts with their items and store
- `GET /receipts/:id` - Get a specific receipt with its items and store
- `POST /receipts` - Create a new receipt and its associated items
- `PATCH /receipts/:id` - Update a receipt
- `DELETE /receipts/:id` - Delete a receipt and its associated items

### Items (Full CRUD)

- `GET /items` - List all items with their store and receipt
- `GET /items/:id` - Get a specific item
- `POST /items` - Create a new item associated with an existing receipt
- `PATCH /items/:id` - Update an item
- `DELETE /items/:id` - Delete an item

## Usage

### 1. Clone and CD into the repo

```bash
git clone git@github.com:ekanarek/phase-3-ruby-project.git
cd phase-3-ruby-project.git
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Migrate and seed the database

```bash
bundle exec rake db:migrate db:seed
```

### 4. Start the server

```bash
bundle exec rake server
```

### 5. Run the CLI

Make sure to do this in a new tab so that the server continues to run.

```bash
ruby cli/main.rb
```

### 6. Try the features!

- View all receipts
- View all items
- Filter receipts or items by store
- View a receipt's full details
- Edit receipt date, store, or associated items
- Delete items from a receipt
- Delete a receipt
- Create a new receipt and associated items
