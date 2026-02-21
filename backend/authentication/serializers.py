from rest_framework import serializers
from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'name', 'avatar_url', 'created_at']
        read_only_fields = ['id', 'created_at']


class GoogleAuthSerializer(serializers.Serializer):
    id_token = serializers.CharField(required=True)


class TokenResponseSerializer(serializers.Serializer):
    access = serializers.CharField()
    refresh = serializers.CharField()
    user = UserSerializer()
