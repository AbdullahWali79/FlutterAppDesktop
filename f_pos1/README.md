# Flutter Desktop POS System

A desktop Point of Sale (POS) system built with Flutter, designed for Windows. The application uses Google Sheets for product inventory management and SQLite for local data storage.

## Features

- 📦 Product inventory management via Google Sheets
- 🛒 Sales management with cart functionality
- 👥 Customer management
- 📊 Sales history tracking
- 🧾 Receipt generation
- 💾 Local data storage using SQLite

## Prerequisites

- Flutter SDK (latest version)
- Windows 10 or later
- Google Cloud Platform account for Google Sheets API access

## Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd f_pos1
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Google Sheets API:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project
   - Enable Google Sheets API
   - Create credentials (Service Account)
   - Download the JSON credentials file
   - Share your Google Sheet with the service account email

4. Configure the application:
   - Run the application
   - Go to Settings
   - Enter your Google Sheet ID (from the URL)
   - Paste your Google Sheets API credentials JSON

## Building for Windows

```bash
flutter build windows
```

The executable will be available in `build/windows/runner/Release/`.

## Usage

1. **Product Management**
   - Set up your Google Sheet with columns: ID, Name, Category, Price, Stock
   - Click "Sync Products" to import products

2. **Making a Sale**
   - Click "New Sale"
   - Add products to cart
   - Enter customer details (optional)
   - Complete the sale

3. **Viewing History**
   - Click "Sales History" to view past sales
   - Expand any sale to see details

## Data Structure

### Google Sheet Format
```
ID | Name | Category | Price | Stock
```

### Local Database
- Products
- Customers
- Sales
- Sale Items

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
