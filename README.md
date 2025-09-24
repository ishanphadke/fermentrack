# Fermentrack - The Smart Fermentation Companion

### Project Proposal: Fermentrack - The Smart Fermentation Companion

**Date:** September 23, 2025

-----

### 1\. Executive Summary

**Fermentrack** is a modern, cross-platform mobile application designed for fermentation enthusiasts, from home cooks to serious hobbyists. Built with **Flutter** for a seamless experience on both iOS and Android, and powered by a robust and scalable **Firebase/GCP** backend, the app aims to solve the most common challenges in fermentation: tracking, timing, and consistency.

The application will operate on a **freemium model**. The core experience allows users to track a limited number of projects, use predefined templates, and receive critical reminders. A premium subscription tier unlocks unlimited projects and the app's flagship feature: real-time project monitoring via **Bluetooth integration** with a custom pH and thermometer sensor. This provides data-driven insights, elevating the craft from guesswork to science.

This proposal outlines the project's vision, target audience, key features, technology stack, system architecture, monetization strategy, and a high-level project timeline.

-----

### 2\. Problem Statement

Fermentation is a rewarding but often complex process. Hobbyists frequently manage multiple projects simultaneously (e.g., sourdough, kombucha, kimchi, beer), each with unique schedules and requirements. As a hobbyist myself, I have run into several challenges:

  * **Tracking Complexity:** Manually tracking feeding schedules, temperature changes, and key dates on paper or in generic note apps is inefficient and prone to error.
  * **Inconsistent Results:** Without precise data on variables like temperature and pH, reproducing a perfect batch is difficult. Guesswork leads to failed or suboptimal results.
  * **Lack of Actionable Reminders:** Forgetting a critical step, like feeding a starter or burping a jar, can ruin a project that has taken weeks of effort.

-----

### 3\. Proposed Solution & Target Audience

Fermentrack will be an all-in-one digital companion that addresses these problems by providing an intuitive interface for managing projects, setting reminders, and, for premium users, collecting precise environmental data.

**Target Audience:**

  * Sourdough bakers
  * Homebrewers (beer, mead, cider)
  * Kombucha and water kefir brewers
  * Vegetable fermenters (kimchi, sauerkraut, pickles)
  * Artisanal cheese and yogurt makers

The app will guide beginners with templates and empower experts with advanced data tools, creating a centralized hub for all their fermentation activities.

-----

### 4\. Key Features

The application will be developed with two distinct tiers:

#### **Free Tier Features:**

  * **User Account Management:** Secure sign-up, login, and profile management via Firebase Authentication.
  * **Project Dashboard:** A central view of all active projects.
  * **Limited Project Tracking:** Users can track up to four active fermentation projects simultaneously.
  * **Fermentation Templates:** Pre-built templates for common projects (Sourdough Starter, Kombucha F1, Sauerkraut) with standard steps and timelines.
  * **Customizable Tasks & Steps:** Ability to add, edit, and reorder steps for any project.
  * **Scheduled Notifications:** Automated push reminders for critical actions like "Feed Starter," "Burp Jar," or "Move to Cold Storage."
  * **Manual Data Entry:** Fields to log manual measurements like temperature, pH, weight, and specific gravity.
  * **Notes & Photo Log:** A dedicated section within each project to add text notes and upload photos to visually track progress.

#### **Premium Tier Features (Subscription-based):**

  * **Everything in the Free Tier, plus:**
  * **Unlimited Projects:** Create and manage an unlimited number of active and archived projects.
  * **Bluetooth Sensor Integration:** The core premium offering. The app will seamlessly connect to a custom Bluetooth-enabled sensor to measure pH and temperature.
  * **Real-time Data Streaming:** Live data from the sensor is streamed to the app and saved to the user's account in Firestore.
  * **Data Visualization:** Interactive charts and graphs showing temperature and pH trends over the lifetime of a project.
  * **Advanced Analytics:** Insights derived from sensor data, such as identifying key fermentation milestones or potential issues based on pH drops or temperature spikes.
  * **Data Export:** Ability to export project data, including notes and sensor readings, as a CSV file for external analysis.
  * **Cloud Sync & Backup:** All data, including high-resolution photos, is automatically backed up and synced across multiple devices.
  * **Real-Time Notifications:** Scheduled notifications will take into account temperature and pH values, updating the times to ensure the steps are taken at the most optimal time. Additionally, drastic changes will also cause alerts to be sent. Notifications will be expanded to include options for text and email alerts.

-----

### 5\. Technology Stack & System Architecture

This project will leverage a modern, scalable, and cost-effective tech stack.

  * **Frontend:** **Flutter** - Allows for the development of a high-performance, natively compiled application for mobile (iOS and Android) from a single codebase. The **flutter_blue_plus** Flutter plugin will be used to connect to the custom probe.
  * **Backend:** **Google Cloud Platform (GCP) / Firebase**
      * **Firebase Authentication:** Handles all user identity management, including email/password and social logins.
      * **Cloud Firestore:** A scalable NoSQL database for storing all user data, including project details, steps, notes, and time-series sensor data.
      * **Cloud Functions for Firebase:** Serverless functions to handle backend logic, such as sending scheduled notifications, processing incoming data streams from the app, and performing data aggregations.
      * **Cloud Storage for Firebase:** To store user-uploaded media like project photos.
      * **Firebase Cloud Messaging (FCM):** To reliably deliver push notifications to users' devices.

#### **System Architecture Diagram:**

```
[ User ]
   |
   v
[ Flutter App (iOS/Android) ] <-----> [ Bluetooth pH/Temp Sensor ]
   |   ^                                     (Premium)
   |   | (Real-time Data Sync)
   v   |
[ Firebase / Google Cloud Platform ]
   |
   +--- [ Firebase Authentication ] (User Login/Signup)
   |
   +--- [ Cloud Firestore ] (Project Data, Sensor Readings, Notes)
   |
   +--- [ Cloud Storage ] (User Photos)
   |
   +--- [ Cloud Functions ] (Notifications, Data Processing)
```

-----

### 6\. Monetization Model

A **freemium model** will be employed to attract a large user base while creating a clear value proposition for the premium subscription.

  * **Free Tier:** Offers core functionality with a project limit. This allows users to experience the app's value and utility, encouraging them to upgrade as their hobby grows.
  * **Premium Tier:** A recurring subscription (e.g., $5.99/month or $59.99/year) will unlock the advanced features. This provides a predictable revenue stream to support ongoing development, server costs, and new feature implementation. In-app purchases will be handled through the Apple App Store and Google Play Store.

-----

### 7\. High-Level Project Timeline

This project can be broken down into four main phases.

  * **Phase 1: Foundation & Core Features (6-8 weeks)**
      * UX/UI design and prototyping.
      * Setup of Firebase project and architecture.
      * Development of user authentication and account management.
      * Implementation of all Free Tier features (project creation, templates, notifications, manual logging).
  * **Phase 2: Premium Features & Bluetooth Integration (5-7 weeks)**
      * Development of subscription management and in-app purchases.
      * Implementation of Bluetooth Low Energy (BLE) connectivity for the sensor.
      * Development of the data streaming pipeline from the app to Firestore.
      * Creation of data visualization charts and graphs.
  * **Phase 3: Testing & Refinement (3-4 weeks)**
      * Internal QA and bug fixing.
      * Closed Alpha/Beta testing with a select group of users.
      * Performance optimization and UI polishing based on feedback.
  * **Phase 4: Deployment & Launch (1-2 weeks)**
      * Preparation of app store listings (screenshots, descriptions).
      * Submission to Apple App Store and Google Play Store for review.
      * Official launch and initial marketing push.

**Total Estimated Timeline:** 15-21 weeks

-----

### 8\. Next Steps

We are confident that Fermentrack has the potential to become an indispensable tool for the growing community of fermentation enthusiasts. We recommend the following next steps:

  * Review this proposal and provide feedback.
  * Approve the project scope and proposed technology stack.
  * Proceed to the detailed UX/UI design and prototyping phase.

We look forward to partnering with you to bring this innovative application to life.