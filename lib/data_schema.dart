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
