from django.conf import settings
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError

from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

from .models import User
from .serializers import UserSerializer, GoogleAuthSerializer


def verify_google_token(token):
    """Verify Google ID token and return user info."""
    client_ids = settings.GOOGLE_CLIENT_IDS
    if not client_ids:
        return None, "Google client IDs not configured"

    for client_id in client_ids:
        try:
            idinfo = id_token.verify_oauth2_token(
                token,
                google_requests.Request(),
                audience=client_id
            )
            if idinfo.get('iss') not in ['accounts.google.com', 'https://accounts.google.com']:
                continue
            return idinfo, None
        except ValueError:
            continue

    return None, "Invalid Google token"


def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


@api_view(['POST'])
@permission_classes([AllowAny])
def google_auth(request):
    """Authenticate user with Google ID token."""
    serializer = GoogleAuthSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    token = serializer.validated_data['id_token']
    idinfo, error = verify_google_token(token)

    if error:
        return Response({'error': error}, status=status.HTTP_401_UNAUTHORIZED)

    google_id = idinfo['sub']
    email = idinfo.get('email', '')
    name = idinfo.get('name', '')
    avatar_url = idinfo.get('picture', '')

    user, created = User.objects.get_or_create(
        google_id=google_id,
        defaults={
            'email': email,
            'name': name,
            'avatar_url': avatar_url,
        }
    )

    if not created:
        user.name = name or user.name
        user.avatar_url = avatar_url or user.avatar_url
        if email and not user.email:
            user.email = email
        user.save()

    tokens = get_tokens_for_user(user)
    user_data = UserSerializer(user).data

    return Response({
        'access': tokens['access'],
        'refresh': tokens['refresh'],
        'user': user_data,
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request):
    """Blacklist refresh token on logout."""
    try:
        refresh_token = request.data.get('refresh')
        if refresh_token:
            token = RefreshToken(refresh_token)
            token.blacklist()
        return Response({'message': 'Logged out successfully'}, status=status.HTTP_200_OK)
    except TokenError:
        return Response({'error': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile(request):
    """Get current user profile."""
    serializer = UserSerializer(request.user)
    return Response(serializer.data)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    """Update user profile (name only)."""
    serializer = UserSerializer(request.user, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
