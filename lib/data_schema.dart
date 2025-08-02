// This file defines the Firestore database schema for the ShopOrbit Shopping App

// Collections:
// 1. users - User accounts (admin, seller, user)
// 2. categories - Product categories
// 3. products - Product catalog
// 4. orders - Customer orders
// 5. reviews - Product reviews

// Schema Structure:

// users collection:
// {
//   id: string (auto-generated)
//   email: string
//   name: string
//   role: string (admin, seller, user)
//   profileImage: string (optional)
//   addresses: array of strings
//   isBlocked: boolean
//   isApproved: boolean (for sellers)
//   createdAt: timestamp
//   updatedAt: timestamp
// }

// categories collection:
// {
//   id: string (auto-generated)
//   name: string
//   description: string
//   imageUrl: string
//   subcategories: array of strings
//   isActive: boolean
//   createdAt: timestamp
//   updatedAt: timestamp
// }

// products collection:
// {
//   id: string (auto-generated)
//   sellerId: string (reference to users)
//   name: string
//   description: string
//   price: number
//   images: array of strings
//   category: string
//   subcategory: string (optional)
//   brand: string (optional)
//   inventory: number
//   averageRating: number
//   reviewCount: number
//   isActive: boolean
//   createdAt: timestamp
//   updatedAt: timestamp
// }

// orders collection:
// {
//   id: string (auto-generated)
//   userId: string (reference to users)
//   sellerId: string (reference to users)
//   items: array of objects {
//     productId: string
//     productName: string
//     productImage: string
//     price: number
//     quantity: number
//   }
//   totalAmount: number
//   status: string (pending, confirmed, shipped, delivered, cancelled)
//   shippingAddress: string
//   paymentMethod: string
//   isPaid: boolean
//   createdAt: timestamp
//   updatedAt: timestamp
// }

// reviews collection:
// {
//   id: string (auto-generated)
//   userId: string (reference to users)
//   userName: string
//   userImage: string
//   productId: string (reference to products)
//   rating: number (1-5)
//   comment: string
//   createdAt: timestamp
//   updatedAt: timestamp
// }

// Add all in this Format

// Certainly! Here’s your **Firestore schema for ShopOrbit** written in the requested, richly annotated format for each collection.

// ### **users collection**

// ```json
// {
//   "id": "string (auto-generated)",           // Document ID (UID from Firebase Auth)
//   "email": "string",                         // User's email address
//   "name": "string",                          // Full name
//   "role": "string",                          // Role: "admin", "seller", or "user"
//   "profileImage": "string (optional)",       // URL to user's profile image
//   "addresses": ["string"],                   // List of addresses (strings or address objects)
//   "isBlocked": "boolean",                    // Whether user is blocked by admin
//   "isApproved": "boolean",                   // Sellers: approved to sell by admin
//   "createdAt": "timestamp",                  // Account creation date
//   "updatedAt": "timestamp"                   // Last update date
// }
// ```


// ### **categories collection**

// ```json
// {
//   "id": "string (auto-generated)",          // Document ID
//   "name": "string",                        // Category name
//   "description": "string",                 // Description of category
//   "imageUrl": "string",                    // URL of category image
//   "subcategories": ["string"],             // List of subcategory names or IDs
//   "isActive": "boolean",                   // Visibility flag
//   "createdAt": "timestamp",                // When category was created
//   "updatedAt": "timestamp"                 // Last update date
// }
// ```


// ### **products collection**

// ```json
// {
//   "id": "string (auto-generated)",         // Document ID
//   "sellerId": "string",                    // User ID (seller)
//   "name": "string",                        // Product name
//   "description": "string",                 // Product description
//   "price": "number",                       // Price
//   "images": ["string"],                    // List of image URLs
//   "category": "string",                    // Category name or ID
//   "subcategory": "string (optional)",      // Subcategory (optional)
//   "brand": "string (optional)",            // Brand name (optional)
//   "inventory": "number",                   // Number in stock
//   "averageRating": "number",               // Average rating (calculated)
//   "reviewCount": "number",                 // Number of reviews
//   "isActive": "boolean",                   // Whether product is active/visible
//   "createdAt": "timestamp",                // Created time
//   "updatedAt": "timestamp"                 // Last modified time
// }
// ```


// ### **orders collection**

// ```json
// {
//   "id": "string (auto-generated)",         // Document ID
//   "userId": "string",                      // Customer User ID
//   "sellerId": "string",                    // Seller User ID
//   "items": [                              // List of purchased items
//     {
//       "productId": "string",                // Product ID
//       "productName": "string",              // Product name (snapshot)
//       "productImage": "string",             // Product image (snapshot)
//       "price": "number",                    // Price at purchase time
//       "quantity": "number"                  // Quantity purchased
//     }
//   ],
//   "totalAmount": "number",                 // Total order amount
//   "status": "string",                      // "pending", "confirmed", "shipped", "delivered", "cancelled"
//   "shippingAddress": "string",             // Delivery address
//   "paymentMethod": "string",               // Payment method used
//   "isPaid": "boolean",                     // Payment status
//   "createdAt": "timestamp",                // Order creation time
//   "updatedAt": "timestamp"                 // Last update time
// }
// ```


// ### **reviews collection**

// ```json
// {
//   "id": "string (auto-generated)",         // Document ID
//   "userId": "string",                      // Reviewer user ID
//   "userName": "string",                    // Reviewer's name (snapshot)
//   "userImage": "string",                   // Reviewer's image URL (snapshot)
//   "productId": "string",                   // Reviewed product ID
//   "rating": "number",                      // 1 to 5 rating
//   "comment": "string",                     // Review text
//   "createdAt": "timestamp",                // Review timestamp
//   "updatedAt": "timestamp"                 // Last edit timestamp
// }
// ```


// #### **Notes:**

// - All `id` fields are auto-generated by Firestore unless you assign custom IDs.
// - **References** (`userId`, `sellerId`, `productId`) are stored as `string` IDs referencing documents in their respective collections.
// - **Array fields** (e.g., `addresses`, `subcategories`, `images`, `items`) use standard Firestore array types.
// - **Timestamps** use Firestore's `timestamp` type.
// - Extra optional or future fields can be easily added as needed per business logic.

// This format clearly documents your e-commerce Firestore schema and can be shared with teammates or used for backend/Flutter model reference.

