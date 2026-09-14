

### **Client Side (Using Flutter & Firebase)**

1. **Login Page**
   The user can sign in using:

   * Google Authentication
   * Email and Password Authentication
     (Implemented using Firebase Authentication in Flutter)

2. **User Profile Page**
   A page where the user can view and edit personal information such as:

   * Name
   * Address
   * Phone number
     (Data is stored and retrieved from Cloud Firestore)

3. **Products Page**
   Displays a list of available products.
   The user can:

   * Browse products
   * View details
   * Add items to cart
     (Products are fetched from Cloud Firestore)

4. **Cart Page & Order Confirmation**
   The user can:

   * View selected items
   * Modify quantity
   * Confirm the order
     (Order data is saved in Cloud Firestore)

5. **Order Tracking Page**
   Allows the user to track order status such as:

   * Pending
   * Processing
   * Delivered
     (Real-time updates are handled using Firebase Realtime Database or Firestore streams)


