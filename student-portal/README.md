# Tshwane College Distance Learning Portal — Beta Demo

A management demonstration prototype for a proposed Tshwane College distance-learning environment.

## Demo workflow

Student login → Dashboard → Course → Lesson → Assignment → Timed Test → Results

Lecturer demonstration → Dashboard → Submissions → Quick actions → Student progress

## Included

- Student sign-in demonstration
- Course dashboard
- Course/module navigation
- Learning lesson
- Learning-material download demonstration
- Assignment upload/submission simulation
- 30-minute timed test with countdown
- Automatic demo scoring
- Results view
- Lecturer dashboard demonstration
- Responsive mobile layout

## Deliberately excluded

NOLTEC registration, payments, real student records and production authentication are intentionally excluded.

NOLTEC remains responsible for registration. The college's existing internal system remains responsible for payments.

## Demo account

Student:
- Email: student@demo.tshwanecollege.edu.za
- Password: demo123

Lecturer:
- Select "View lecturer demonstration" on the login page.

## Important

This is a prototype. GitHub Pages is suitable for this public static demonstration, but it is not the production platform for confidential student information or server-side assessment controls. GitHub Pages publishes static files and does not provide server-side application logic.

## Beta direction

For a real beta, the next stage should introduce authenticated accounts, a database, protected assignment storage, lecturer/student roles, server-side timed assessment controls, audit logging, backups and controlled access. Supabase Auth + PostgreSQL + Row Level Security is one possible architecture.