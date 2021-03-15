# README

### 0. change local db in file db.csv
### 1. run `docker-compose up -d`
### 2. go to http://localhost:3000/api-docs
### 3. try query from `api/shipping/search`
with body smth like this
```json
{
  "shippingRegion": "us",
  "orderedItems": [
    {
      "itemName": "black_mug",
      "count": 3
    }
  ]
}
```
