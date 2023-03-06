# Tiny URL 

It uses nanoid to generate a random string of 13 characters and stores it in a database. The URL is then served at `http://localhost:3000/<random-string>`.

With speed 100 IDs/second ~25 years needed, in order to have a 1% probability of at least one collision.
https://zelark.github.io/nano-id-cc/

It uses MongoDB to allow for easy scaling.

## Requirements
- Ruby 3.1.2
- Docker

## Installation
- `bundle install`
- Copy `.env.example` to `.env` and fill in the values

## Usage
- `docker-compose up` in order to start the database
- `./bin/dev` to start the server
- Open `http://localhost:3000` in your browser and enter a URL


## API Endpoints
- `POST /tiny_urls.json` with a JSON body of `{"url": "https://example.com"}` to create a new URL
Example:
```bash
curl -X POST -H "Content-Type: application/json" -d '{"url": "https://example.com"}' http://localhost:3000/tiny_urls.json
```

Expected response:
```json
{
  "_id": {"$oid":"6406400a9f880b2ecabd666f"},
  "full_url":"https://example.com",
  "short_url":"http://localhost:3000/MXEn_n1Ed-yUo"
}
```

- `GET /tiny_urls/:id.json` to get the URL for the given ID
Example:
```bash
curl http://localhost:3000/tiny_urls/6406400a9f880b2ecabd666f.json
```

Expected response:
```json
{
  "full_url":"https://example.com",
  "short_url":"http://localhost:3000/MXEn_n1Ed-yUo"
}
```
