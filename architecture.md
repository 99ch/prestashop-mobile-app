# MarketNest - Multi-Vendor Marketplace Architecture

## Overview
MarketNest is a complete multi-vendor marketplace application inspired by Amazon's UI, with Flutter frontend and PrestaShop backend integration through a custom PHP proxy.

## Architecture Pattern
- **Clean Architecture**: Separation of concerns with distinct layers
- **MVVM Pattern**: Model-View-ViewModel with Provider for state management
- **Repository Pattern**: Data access abstraction through services

## Project Structure

### Frontend (Flutter)
```
lib/
├── models/              # Data models
│   ├── customer_model.dart
│   ├── product_model.dart
│   ├── category_model.dart
│   ├── cart_model.dart
│   ├── order_model.dart
│   └── vendor_model.dart
├── services/            # API and business logic
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── cart_service.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   └── vendor_provider.dart
├── views/               # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   ├── products/
│   │   ├── product_listing_screen.dart
│   │   └── product_detail_screen.dart
│   ├── vendors/
│   │   ├── vendor_listing_screen.dart
│   │   └── vendor_detail_screen.dart
│   ├── cart/
│   │   └── cart_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/             # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── product_card.dart
│   ├── vendor_card.dart
│   └── cart_item_widget.dart
├── theme.dart           # App theming
└── main.dart            # App entry point
```

### Backend (PHP Proxy)
- **proxy.php**: Custom middleware for PrestaShop API
- **API Endpoints**: Login, Signup, Products, Categories, Cart, Orders, Vendors
- **Data Transformation**: JSON to XML conversion for PrestaShop compatibility

## Key Features

### Authentication
- User registration and login
- JWT-like session management
- Password verification with bcrypt
- Persistent authentication state

### Product Management
- Product listing with pagination
- Product search and filtering
- Category-based browsing
- Product details with images
- Rating and review system

### Shopping Cart
- Add/remove products
- Quantity management
- Local storage fallback
- Cart persistence across sessions

### Multi-Vendor Support
- Vendor listing and profiles
- Vendor-specific product catalogs
- Vendor ratings and reviews
- Contact seller functionality

### Responsive Design
- Mobile-first approach
- Tablet and desktop support
- Modern Material Design 3
- Smooth animations and transitions

## State Management
- **Provider Pattern**: Reactive state management
- **Separation of Concerns**: UI, business logic, and data layers
- **Error Handling**: Comprehensive error states and recovery
- **Loading States**: User-friendly loading indicators

## Data Flow

1. **User Interaction** → View
2. **View** → Provider (State Management)
3. **Provider** → Service (Business Logic)
4. **Service** → API (Data Layer)
5. **API** → PrestaShop Backend
6. **Response** flows back through the same chain

## Security Considerations
- API key protection
- Password hashing (handled by PrestaShop)
- Input validation
- Error message sanitization
- Secure data transmission

## Performance Optimizations
- Image caching with cached_network_image
- Lazy loading for product lists
- Efficient state management
- Minimal API calls
- Local cart storage

## Testing Strategy
- Unit tests for models and services
- Widget tests for UI components
- Integration tests for complete flows
- API endpoint testing

## Deployment
- Flutter web/mobile deployment
- PHP proxy server deployment
- PrestaShop backend configuration
- Database setup and migration

## Future Enhancements
- Push notifications
- Real-time chat with vendors
- Advanced filtering and sorting
- Order tracking
- Payment gateway integration
- Vendor dashboard
- Analytics and reporting