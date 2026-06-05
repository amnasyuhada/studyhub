
---

# 🎓 INFO 4335 — Section 01  
### 🌐 Mobile Application Development  
**👨‍🏫 Instructor:** Mohd Khairul Azmi bin Hassan  
**👥 Group:** 2    

---

## 👩‍💻 GROUP MEMBERS 

| 🧑‍🤝‍🧑 Name                                           | 🆔 Student ID |
|------------------------------------------------------|---------------|
| Nurul Iman Binti Md Kamal                            | 2228908       |
| Siti Nursajeedah binti Shabuddin                     | 2313226       |
| Farah Nur Athirah binti Sukardan                     | 2310960       |
| Amna Syuhada binti Mohamad Aminudin                  | 2311986       |

---
## 📑 PROJECT TITLE

### StudyHub: Student Academic Management System

## INTRODUCTION
The constant integration of digital technologies in the lives of students has begun to transform how they approach and manage their academics. In higher learning institutions, students have numerous tasks to juggle-attending classes, submitting assignments, studying for exams and collating all of their relevant study material. Keeping track of these academic duties is imperative in maintaining efficiency and academic accomplishment. However, a significant amount of students continue to organize and track their academics using various applications, or traditional methods. There have been several challenges with managing an academic life, such as losing track of assignments, difficulty in sorting academic materials and effective time management.

Thus, this project entails the creation ofStudyHub, a mobile application for academic management that helps students keep track of and organize their studies efficiently. In this application, the students can organize assignments, keep study notes and other academic material for retrieval, set study times, and keep a general overview of their academic progress. By combining all of these core functions into one application, StudyHub can ultimately boost a students learning experience.

Additionally, StudyHub uses the modern technologies in mobile applications in order to provide a simple, readily available and time-efficient platform to manage academics. The system is to encourage the use of more study habits, with the main goal of helping students get to their academic goals.

## OBJECTIVES
The objectives of the StudyHub application:

**2.1 Provide an integrated academic management tool**

The study hub application would centralize and facilitate important academic management functions such as assignment tracking, study planning, and notes management, making them easily accessible and convenient for students.

**2.2 Optimize student productivity and time management**

This feature of the app would aid students in managing academic responsibilities by providing students with an efficient system to track assignments, monitor deadlines, and plan out study sessions thereby maintaining better organization and an optimized use of time.

**2.3 Aid student learning and academic performance**

The study hub would provide structure for a more organized study session as students would be able to organize learning resources, track their academic engagement, and encourage continuous student engagement in learning.

## TARGET USERS
**3.1 University & College Students**

University & college students are one of the target users. Students have many different courses, assignment, projects and examinations to deal with at the same time, with the aid of the application they can have the academic tasks and activities in an organized manner and always keep the eye on deadlines. They are helped to keep the study schedules in an efficient way.

**3.2 Foundation & diploma students**

Foundation and diploma students can learn effective study habits and organization skills as they begin to enter the high level of education with the aid of the application. The application provides a structured frame to help in planning and managing study activities.

**3.3 Independent learners**

Independent learners such as online courses users, certification programs learners or self-study students, can use the application to keep study materials in order, schedule activities and trace their progress in learning activities.

## FEATURES AND FUNCTIONALITIES

| **Feature**       | **Description** |
|-------------------|-----------------|
| **Login / Register** | Allow users to register and login into their account.<br><br>UI Components: Form, TextFormField, ElevatedButton, Text, Icon |
| **Assignment Tracker** | Enable users to manage assignments (add, edit, delete, update), track due date and view assignment completion status.<br><br>UI Components: ListView, Card, Text, ElevatedButton, Dismissible  |
| **Study Timetable** | Create, organize and view the study schedule.<br><br>UI Components: ListView, Card, Text, ElevatedButton  |
| **Notes Management** | Allow upload, manage and access study materials.<br><br>UI Components: ListView, Card, Image, ElevatedButton |
| **Quiz Module** | Self assessment through quizzes and performance tracking.<br><br>UI Components: Text, Form, TextFormField, RadioListTile, DropdownButtonFormField, ElevatedButton |
| **Study Groups** | Collaborative learning through creation of groups and announcements.<br><br>UI Components: Card, ElevatedButton, ListView, TextField |  
| **Progress Dashboard** | Quick overview of assignments, quiz performances and academic or study progress.<br><br>UI Components: Card, ListView, Text, Icon |
| **Notifications** | Reminders and alerts for schedule, assignments and quizzes.<br><br>UI Components: Card, Text, Icon, ListTile |
| **Profile / Settings** | Edit user profile information. Manage basic account settings. Logout functionality.<br><br>UI Components: Text, TextFormField, ElevatedButton, IconButton, Text |




## UI MOCK-UP

### 1. Login / Register Screen

<img width="400" height="700" alt="image" src="https://github.com/user-attachments/assets/8edf7470-b03f-4685-8016-805d837bc8e7" />

This screen allows users to authenticate into the StudyHub system. It provides input fields for email and password, along with options for user registration and password recovery. Successful authentication grants access to the main application features.

### 2. Home Dashboard

<img width="400" height="700" alt="image" src="https://github.com/user-attachments/assets/e13a42a5-b2f2-40d0-b370-bae98f8ffc05" />

The Home Dashboard serves as the central overview screen of the application. It displays a summary of the user’s academic activities, including upcoming assignments, study progress and performance statistics. It also provides quick navigation to other core modules.

### 3. Assignment Tracker Screen

<img width="400" height="700" alt="image" src="https://github.com/user-attachments/assets/e88fcfef-99be-4e6c-9202-78da93082d6e" />

This screen enables users to manage their academic assignments efficiently. Users can add, view, update and delete assignment records as well as track their completion status and due dates. It helps students organize and monitor their coursework deadlines.

### 4. Notes Management Screen

<img width="400" height="700" alt="image" src="https://github.com/user-attachments/assets/aeb4b4a9-457e-40e1-b6d3-e453b163947d" />

The Notes Management screen allows users to upload, organize and access study materials in various formats such as PDF and images. Notes can be categorized by subjects for easier retrieval, supporting efficient academic revision and resource management.

### 5. Study Timetable (Calendar Screen)

<img width="400" height="700" alt="image" src="https://github.com/user-attachments/assets/262c2a28-62a6-4247-aa02-02aadbc906e4" />

This screen provides a calendar-based interface for scheduling study sessions and academic activities. Users can view planned tasks by date, add new schedules and manage their study routine effectively to improve time management and consistency.

## ARCHITECTURE / TECHNICAL DESIGN

<img width="1000" height="600" alt="image" src="https://github.com/user-attachments/assets/22741cea-fe02-4653-a2ae-50cbbb025977" />

The StudyHub application adopts a **client-server architecture** consisting of an Input Layer, Flutter Frontend Layer and Firebase Backend Services Layer. Users interact with the system by managing assignments, uploading notes and scheduling study timetables through the Flutter application.

The **Flutter Frontend** contains UI screens, local application logic and **Provider-based state management** to manage data flow and update the user interface efficiently. The application communicates with Firebase services through a service layer to process user requests and retrieve data.

The **Firebase Backend Services** include Firebase Authentication for user management, Cloud Firestore for storing academic data, Firebase Storage for managing uploaded files and Firebase Cloud Messaging for sending notifications and reminders.

The project follows a modular Flutter structure consisting of **models, screens, widgets, services, providers and utils** folders, ensuring better code organization, maintainability and scalability throughout the development process.

### State Management Approach

StudyHub uses the **Provider** package for state management. Provider acts as an intermediary between the user interface and Firebase services, allowing data changes to be managed efficiently and reflected automatically across the application. This approach promotes separation of concerns, improves code maintainability and is well-suited for medium-scale Flutter applications developed in a team environment.

## DATA MODEL
<img width="906" height="551" alt="StudyHub-FlowChart drawio" src="https://github.com/user-attachments/assets/46f4deab-18d7-4d20-9b87-a8169d21e440" />
The data model for StudyHub is designed using a Firestore collection–document structure, where data is organized based on ownership and functionality.

The main collections are Users, Quizzes, and Study Groups.

Each user document stores personal academic data such as assignments, study schedules, notes, notifications, and quiz results in subcollections. This is because these data are user-specific and private, meaning each student only accesses their own records.

The quizzes collection stores quiz information such as questions and categories, which are shared resources accessible by all users.

The studyGroups collection manages collaborative learning features. Each group contains members and announcements, where announcements are stored as a subcollection because they belong specifically to a group context.

This structure improves data organization, scalability, and efficient retrieval, especially for user-centered features like dashboards and progress tracking.

## FLOWCHART DIAGRAM
<img width="641" height="508" alt="StudyHub-DataModel drawio" src="https://github.com/user-attachments/assets/e7eccdf0-faca-4f10-9751-d88554854372" />
The flowchart represents the overall user interaction and navigation flow within the StudyHub application.

The process begins with user authentication, where users either register a new account or log in to access the system. After successful login, users are directed to the Home Dashboard, which acts as the central hub of the application.

From the dashboard, users can navigate to different modules including Assignment Tracker, Study Timetable, Notes Management, Quiz Module, Study Groups, and Profile Settings.

Each module allows users to perform specific tasks such as adding and managing assignments, scheduling study sessions, accessing learning materials, participating in quizzes, and collaborating in study groups.

After completing any task, users can return to the dashboard for easy navigation across other features. This flow ensures a simple, centralized, and user-friendly experience, allowing students to manage all academic activities within one integrated system.

## REFERENCES
+ GeeksForGeeks (2025, July 23rd), Data Modeling Basics for Firestore, https://www.geeksforgeeks.org/firebase/data-modeling-basics-for-cloud-firestore/
+ Nikhil Garg et. al. (2024, April). Flutter Technology with Firebase Database. _International Journal of Research Publication and Reviews, Vol 5, no 4, pp 2368-2371_


