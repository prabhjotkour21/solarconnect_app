# API Integration Notes

## Base URL

- Base URL: http://localhost:3000/api/v1

## Auth Endpoints

### POST /auth/login

Request:
{
"email": "test@gmail.com",
"password": "12345678"
}

Expected response:
{
"accessToken": "...",
"refreshToken": "...",
"user": { ... }
}

### POST /auth/logout

Requires Bearer token.

### POST /auth/refresh

Request:
{
"refreshToken": "..."
}

### GET /auth/me

Requires Bearer token.

## User Profile Endpoints

### GET /users/profile

Requires Bearer token.

### PUT /users/profile

Request:
{
"firstName": "Prabhjot",
"lastName": "Kaur",
"email": "test@gmail.com"
}

### PUT /users/preferences

Request:
{
"theme": "dark",
"language": "en"
}

### PUT /users/password

Request:
{
"currentPassword": "12345678",
"newPassword": "87654321"
}

## Frontend Usage

- Use the shared service layer from the services folder.
- Token is stored locally using SharedPreferences.
- All authenticated calls automatically send the Bearer token.
