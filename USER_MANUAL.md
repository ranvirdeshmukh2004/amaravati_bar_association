# Amaravati Bar Association - End-User Manual

Welcome to the Amaravati Bar Association management software. This application has been designed to streamline member administration, subscription tracking, and document generation (receipts, certificates, and voter lists) in a fast, robust, and offline-first environment. 

This manual provides step-by-step flows to guide you through the software’s core functionalities.

---

## Table of Contents
1. [Getting Started](#1-getting-started)
2. [Dashboard Overview](#2-dashboard-overview)
3. [Member Management](#3-member-management)
    - [Adding a New Member](#adding-a-new-member)
    - [Updating Member Details](#updating-member-details)
4. [Subscription Management](#4-subscription-management)
    - [Recording a New Subscription](#recording-a-new-subscription)
    - [Generating a Receipt](#generating-a-receipt)
5. [Document Generation](#5-document-generation)
    - [Generating an Experience Certificate](#generating-an-experience-certificate)
    - [Generating Voter Lists](#generating-voter-lists)
6. [Settings & Administration](#6-settings--administration)
    - [Changing User Password](#changing-user-password)
7. [System Data & Offline Mode](#7-system-data--offline-mode)

---

## 1. Getting Started

### Launching the Application
1. Double-click the **Amaravati Bar Association** shortcut on your Desktop (or run the executable from its installed folder).
2. You will be greeted by the **Login Screen**.
3. **Login Details**:
   - Enter your authorized email address and password.
   - Click **Login**.

> **Note on Data:** Because the application features an offline-first architecture, you can log in and use it even without an active internet connection. Your data remains perfectly safe locally.

---

## 2. Dashboard Overview

Upon successful login, you will see the **Main Dashboard**. The dashboard is divided into two primary areas:

1. **Sidebar Navigation (Left)**:
   - **Dashboard**: High-level statistics (Total Members, Active Members, Total Subscriptions Collected, etc.).
   - **Members Registry**: View, add, search, and manage bar association members.
   - **Subscriptions**: Manage un-paid dues, record new payments, and view past transactions.
   - **Reports & Export**: Generate mass lists (e.g., Provisional Voter List, Pending Dues).
   - **Settings**: Adjust application preferences and change passwords.
   - **SMS Panel**: *(Currently disabled. Reach out @works.ranvirdeshmukh.com to activate this feature).*

2. **Main Workspace (Right)**: Activity-specific views depending on the sidebar selection.

---

## 3. Member Management

### Adding a New Member
1. Click on **Members Registry** in the left sidebar.
2. Click the **+ Add New Member** button (usually at the top right).
3. The entry form will slide out or pop up.
4. **Fill out the required Details**:
   - Name
   - Registration Number
   - Enrollment Dates (Date of Application, Date of Enrollment)
   - Address
   - Mobile Number
   - Email ID
5. Once finalized, click **Save Member**. 
6. **Optional Fast-Track**: Immediately after adding a member, the system may prompt you to add their initial **Subscription Payment**. You can choose to "Record Subscription Now" or "Skip for Later".

### Updating Member Details
1. Navigate to the **Members Registry**.
2. Use the **Search Bar** to find a specific member by Name or Registration Number.
3. Click the **Edit** button (pencil icon) next to their name.
4. Modify any outdated fields (e.g., updating a phone number or address).
5. Click **Update** to save the changes.

---

## 4. Subscription Management

### Recording a New Subscription (Payment)
1. Navigate to the **Subscriptions** panel from the sidebar, or click on a specific member from the Members Registry and click **Add Payment**.
2. Select the specific **Year / Dues Category** the payment applies to.
3. Enter the **Transaction Amount** and the **Payment Mode** (Cash, Cheque, UPI, etc.).
4. Click **Record Payment**. The member's status will automatically be evaluated. If they have paid all outstanding dues, they will be marked as **"Fully Paid"**.

### Generating a Receipt
1. Go to the **Subscriptions** tab and find a recorded transaction.
2. Click the **Download Receipt** button.
3. A PDF receipt will be instantly generated using standard Bar Association formatting and saved locally to your system.
4. You can click **Open** to immediately view the PDF and print it for the member.

---

## 5. Document Generation

The application can rapidly generate formatted documents for members.

### Generating an Experience Certificate
Members often require a certificate of experience for various legal purposes.
1. Navigate to the **Members Registry**.
2. Locate the specific member using the search bar.
3. Click on the **Actions** dropdown (or the direct document icon) and select **Download Experience Certificate**.
4. The system will extract the member's Name, Enrollment Dates, and Registration Number, and dynamically populate it into a standardized single-page DOCX template.
5. The file is automatically saved as `MemberName_Experience_Certificate_[Date].docx` on your system. It can be opened directly in Microsoft Word and printed.

### Generating Voter Lists
The system can export complex lists directly to Excel (XLSX).

1. Click on **Reports & Export** (or **Voter List Generator**) in the sidebar.
2. Choose the type of list you want to generate:
   - **Provisional Voter List**: This strict list **will only include** members who are marked as both **Active** and **Fully Paid** (no outstanding dues).
   - **Pending People Details**: A list of individuals who are Defaulters.
3. Optionally select custom fields you want included in the export file (e.g., include mobile numbers, omit addresses).
4. Click **Generate List**. The resulting Excel file will be downloaded immediately.
> *Note: If no members meet the criteria for a Provisional Voter List, the system will warn you and prevent the generation of an empty file.*

---

## 6. Settings & Administration

### Changing User Password
For security, it is advised to change the user password periodically.
1. Click **Settings** in the bottom left of the sidebar.
2. Under the "Account" section, navigate to **Change User Password**.
3. You will be prompted to re-authenticate by entering your **Current Password**.
4. If correct, you will be allowed to type your **New Password** and **Confirm New Password**.
5. Click **Change Password** to finalize.

---

## 7. System Data & Offline Mode

Your system features a highly robust **Local-First Architecture**. 
* **What this means for you**: Your application connects to a local database directly stored on your computer. 
* **Reliability**: If the internet goes down, or if the Firebase backup server drops completely out of sync, the application **will not stop working**. 
* **Data Security**: All data entries, past receipts, and certificates remain 100% accessible locally and can be exported at any time. 

---

### Need Help?
If you encounter any bugs, system crashes, or require new features (such as unlocking the SMS Panel), please contact your system administrator or reach out at **@works.ranvirdeshmukh.com**.
