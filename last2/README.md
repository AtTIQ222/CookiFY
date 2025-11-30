# CooKiFy - Home Chef Platform

## Description

CooKiFy is a web-based platform that connects food lovers with talented local chefs who prepare and deliver delicious home-cooked meals. The platform features a comprehensive system for recipe management, order processing, chef profiles, and customer reviews.

## Features

### For Customers
- Browse and search recipes by category
- Add recipes to cart and place orders
- Multiple payment options (Cash, JazzCash, EasyPaisa, Card)
- Order tracking and history
- Rate and review recipes and chefs
- Address management
- Coupon system for discounts

### For Chefs
- Create and manage recipe profiles
- View and manage orders
- Track earnings and ratings
- Update order status
- Recipe image upload

### For Admins
- Approve and manage chef accounts
- View comprehensive reports (orders, revenue, chefs)
- Manage coupons and promotions
- Monitor platform activity

## Technology Stack

- **Frontend**: JSP, HTML5, CSS3, JavaScript
- **Backend**: Java Servlets
- **Database**: MySQL
- **Server**: Apache Tomcat
- **Architecture**: MVC Pattern

## Prerequisites

- Java JDK 8 or higher
- Apache Tomcat 9 or higher
- MySQL 5.7 or higher
- MySQL Connector/J (JDBC driver)

## Installation and Setup

### 1. Database Setup
1. Install MySQL Server
2. Create a new database:
   ```sql
   CREATE DATABASE home_chef_db;
   ```
3. Run the database setup script:
   ```bash
   mysql -u root -p home_chef_db < DATABASE_SETUP.sql
   ```

### 2. Application Setup
1. Clone or download the project
2. Place the project in Tomcat's webapps directory:
   ```
   C:\xampp\tomcat\webapps\last2\
   ```
3. Update database credentials in `src/homechef/util/DatabaseConnection.java`:
   ```java
   private static final String PASSWORD = "your_mysql_password";
   ```
4. Compile the Java classes:
   ```bash
   cd src
   javac -cp "path/to/mysql-connector-java.jar" com/homechef/util/*.java
   ```
5. Copy compiled classes to WEB-INF/classes/

### 3. Tomcat Configuration
1. Start Tomcat server
2. Access the application at: `http://localhost:8080/last2/`

## Database Schema

The application uses a normalized 3NF database schema with the following main tables:
- User, Role, User_Role
- ChefProfile
- Category, Recipe
- Address, MasterOrder, OrderItems
- Payment, Rating
- Coupon

## Default Accounts

### Admin Accounts
- Username: admin1, Password: admin123
- Username: admin2, Password: admin123

### Chef Accounts
- chef_ali, chef_asim, chef_fatima, etc. (Password: chef123)

### Customer Accounts
- user_zaid, user_dada, etc. (Password: user123)

## Project Structure

```
last2/
├── css/                    # Stylesheets
├── images/                 # Static images
├── includes/              # JSP includes (header, footer)
├── src/                   # Java source files
│   └── homechef/
│       └── util/
├── WEB-INF/
│   ├── classes/           # Compiled classes
│   ├── jsp/              # JSP files
│   └── web.xml           # Web configuration
├── *.jsp                  # Main JSP pages
├── DATABASE_SETUP.sql     # Database schema
└── README.md             # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is for educational purposes.

## Support

For issues or questions, please check the code comments or create an issue in the repository.