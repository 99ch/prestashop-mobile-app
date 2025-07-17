# MarketNest Backend - PrestaShop API Proxy

## Overview
This PHP proxy serves as a middleware between the Flutter frontend and PrestaShop backend, handling JSON to XML conversion and authentication.

## Setup

### Prerequisites
- PHP 7.4 or higher
- PrestaShop 8.x installation
- Web server (Apache/Nginx)
- PrestaShop Web Service enabled

### Installation

1. **Place the proxy.php file** in your web server directory
2. **Configure PrestaShop Web Service**:
   - Go to Advanced Parameters > Webservice
   - Enable Web Service
   - Generate an API key
   - Set permissions for resources

3. **Environment Variables**:
   ```bash
   export PRESTASHOP_API_KEY="your_api_key_here"
   ```

4. **Update Configuration**:
   - Edit the `$baseApiUrl` in proxy.php to match your PrestaShop installation
   - Adjust CORS settings if needed

## API Endpoints

### Authentication
- `POST /login` - User login
- `POST /signup` - User registration

### Products
- `GET /products` - List products
- `GET /products/{id}` - Get product details
- `POST /products` - Create product (admin)
- `PUT /products/{id}` - Update product (admin)
- `DELETE /products/{id}` - Delete product (admin)

### Categories
- `GET /categories` - List categories
- `GET /categories/{id}` - Get category details

### Cart
- `GET /carts` - Get cart
- `POST /carts` - Add to cart
- `PUT /carts/{id}` - Update cart
- `DELETE /carts/{id}` - Remove from cart

### Orders
- `GET /orders` - List orders
- `POST /orders` - Create order
- `GET /orders/{id}` - Get order details

### Vendors (Multi-vendor support)
- `GET /kbsellers` - List vendors
- `GET /kbsellers/{id}` - Get vendor details
- `GET /kbsellerproducts` - List vendor products

## Request/Response Format

### Login Request
```json
{
  "email": "user@example.com",
  "passwd": "password123"
}
```

### Login Response
```json
{
  "success": true,
  "customer": {
    "id": "1",
    "firstname": "John",
    "lastname": "Doe",
    "email": "user@example.com"
  },
  "token": "encoded_token_here"
}
```

### Signup Request
```json
{
  "customer": {
    "firstname": "John",
    "lastname": "Doe",
    "email": "user@example.com",
    "passwd": "password123"
  }
}
```

## Error Handling

The proxy returns standardized error responses:

```json
{
  "error": "Error message",
  "details": "Additional error details"
}
```

Common HTTP status codes:
- 200: Success
- 400: Bad Request
- 401: Unauthorized
- 404: Not Found
- 405: Method Not Allowed
- 500: Internal Server Error

## Security Features

- API key protection
- Input validation
- Error logging
- CORS configuration
- Password verification (bcrypt)

## Logging

All requests and errors are logged to `api_proxy.log` with timestamps.

## Testing

Use the provided `sample_data.json` for testing purposes. You can import this data into your PrestaShop installation or use it as reference for API responses.

## Troubleshooting

1. **CORS Issues**: Ensure CORS headers are properly configured
2. **API Key**: Verify the API key is correct and has proper permissions
3. **PrestaShop URL**: Check the base API URL configuration
4. **PHP Version**: Ensure PHP 7.4+ is installed
5. **Web Service**: Verify PrestaShop Web Service is enabled

## Performance Optimization

- Enable PHP OPcache
- Use HTTP/2 if available
- Implement response caching for static data
- Monitor API response times

## Production Deployment

1. Remove debug information
2. Enable error logging to files
3. Set up monitoring and alerting
4. Configure proper SSL certificates
5. Implement rate limiting
6. Set up backup and recovery procedures