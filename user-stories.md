# Concept: Personal Shopping Tracker

## Feature 1: View Receipts and Receipt Items

### User Story

As a user, I want to view my receipts from a specific date and/or store, as well as the list of items from a specific receipt.

### Details

The `get /receipts` endpoint should GET all receipts and display the date and sum total for each receipt. There should be an optional parameter built into this to filter by store. The `get /receipts/:id` endpoint should show only a specific receipt, with all of that receipt's items nested inside.

## Feature 2: View Purchased Items

### User Story

As a user, I want to view all of my purchased items from a specific date and/or store, and see my total costs.

### Details

The `get /items` endpoint should GET all items, display the name and price for each, and the sum total cost of all items in the search. There should be optional queries built into this to filter by date and/or store.

## Feature 3: Add a New Receipt

### User Story

As a user, I want to add a new receipt to my tracker, with information about what I bought and where I bought it from.

### Details

Users can send a POST request to `/receipts` with the date, name of the store, and names + prices of all purchased items. This also sends POST requests to `/items` with the item information, and checks `/stores` to see if the store already exists & creating it if not.

## Feature 4: Update an Existing Receipt

### User Story

As a user, I want to update the date and/or item information of an existing receipt.

### Details

Users can send a PATCH request to `/receipts/:id` with a new date. They can also send a PATCH request to `/items/:id` to update an item's name or price, or update the name of a store via `/stores/:id`.

## Feature 5: Delete a Receipt or Item

### User Story

As a user, I want to delete a receipt or item from my tracker.

### Details

Users can send DELETE requests to `/receipts:id` or `/items/:id`. If an entire receipt is deleted, so are the items associated with it. If a store no longer has any receipts associated with it, the store is also deleted.
