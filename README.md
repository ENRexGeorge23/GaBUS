# GaBus - Bus Booking & Management System

GaBus is a comprehensive, real-time bus booking and management application built with Flutter and Firebase. It provides a seamless experience for three distinct user roles: Passengers, Bus Drivers, and Administrators. Passengers can book seats from terminals or while on the road, track buses in real-time, and manage their bookings. Drivers can manage their routes, status, and view earnings. Admins have a full overview of the system, including earnings, bus tracking, and user verification.

## Table of Contents
- [About The Project](#about-the-project)
- [Key Features](#key-features)
  - [Passenger Features](#passenger-features)
  - [Driver Features](#driver-features)
  - [Admin Features](#admin-features)
- [Technology Stack](#technology-stack)

## About The Project

The GaBus project aims to modernize the public bus transportation experience by providing a centralized platform for booking, tracking, and management. It addresses the common challenges faced by commuters, such as uncertainty in bus schedules, difficulty in securing seats, and lack of real-time information.

-   **For Passengers:** A user-friendly mobile app to find buses, book seats in advance from a terminal or book available seats on a nearby bus, pay securely through a built-in wallet, and track the bus's location live.
-   **For Bus Drivers:** A dedicated interface to manage their operational status (e.g., on-duty for a specific route, logged off), view seat occupancy in real-time, handle walk-in passengers, and track their earnings per trip and daily.
-   **For Administrators:** A powerful dashboard to oversee the entire operation. This includes registering new buses, verifying user identities for discounts, monitoring the real-time location of all active buses, and analyzing system-wide earnings reports.

## Key Features

### Passenger Features
-   **User Authentication:** Secure registration, login, and password management.
-   **Real-time Bus Tracking:** View the live location of active buses on a map.
-   **Flexible Booking:**
    -   **Terminal Booking:** Book seats for scheduled trips from a terminal.
    -   **On-the-Road Booking:** Find nearby buses and book available seats.
-   **Interactive Seat Selection:** A visual seat map to choose and book preferred seats.
-   **Wallet System:** A secure in-app wallet for cashless payments.
-   **Profile & Verification:** Manage user profiles and submit documents for verification to avail discounts (e.g., for students, seniors).
-   **Booking History:** View past and upcoming trip details and receipts.

### Driver Features
-   **Driver Authentication:** Secure login for authorized bus drivers.
-   **Status Management:** Set the bus's current status (e.g., `CSBT to Bato`, `Logged Off`).
-   **Live Location Broadcasting:** Transmit the bus's real-time GPS location.
-   **Seat Management Interface:** View the real-time status of all seats (available, reserved, occupied) and manage bookings for walk-in passengers.
-   **Earnings Dashboard:** Track earnings on a per-trip and daily basis.

### Admin Features
-   **Admin Authentication:** Secure login for administrators.
-   **System-wide Earnings Dashboard:** View and analyze total earnings on a per-trip, daily, and monthly basis.
-   **Live Bus Fleet Tracking:** A master map view showing the real-time location of all buses currently on the road.
-   **User Verification Portal:** Review and approve/reject user verification requests for discounts.
-   **Bus Registration:** Add new buses and their schedules to the system.

## Technology Stack

-   **Framework:** Flutter
-   **Programming Language:** Dart
-   **Backend & Database:** Firebase
    -   **Authentication:** For user, driver, and admin sign-in.
    -   **Cloud Firestore:** For storing persistent data like user profiles, bus details, and transactions.
    -   **Realtime Database:** For live data synchronization, including bus locations and seat statuses.
    -   **Firebase Storage:** For storing user-uploaded verification images.
-   **State Management:** Provider
-   **Mapping & Geolocation:**
    -   **Google Maps Flutter:** For displaying maps and routes.
    -   **Geolocator:** For accessing device GPS.
    -   **Permission Handler:** For managing location permissions.
