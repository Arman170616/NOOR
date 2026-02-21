"""
Quick script to create a Django superuser for admin access.
Run: python create_superuser.py
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'quran_app.settings')
django.setup()

from authentication.models import User

email = input("Admin email: ").strip()
password = input("Admin password: ").strip()

if User.objects.filter(email=email).exists():
    print(f"User {email} already exists.")
else:
    User.objects.create_superuser(
        email=email,
        password=password,
        first_name="Admin",
        last_name="User",
    )
    print(f"Superuser {email} created successfully.")
