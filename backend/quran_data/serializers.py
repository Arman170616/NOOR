from rest_framework import serializers
from .models import FavoriteAyah


class FavoriteAyahSerializer(serializers.ModelSerializer):
    class Meta:
        model = FavoriteAyah
        fields = [
            'id', 'surah_number', 'ayah_number', 'number_in_quran',
            'surah_name', 'surah_name_arabic', 'arabic_text',
            'translation', 'audio_url', 'emotion_context', 'note', 'added_at'
        ]
        read_only_fields = ['id', 'added_at']


class AddFavoriteSerializer(serializers.Serializer):
    surah_number = serializers.IntegerField(min_value=1, max_value=114)
    ayah_number = serializers.IntegerField(min_value=1)
    number_in_quran = serializers.IntegerField(required=False, default=0)
    surah_name = serializers.CharField(max_length=100)
    surah_name_arabic = serializers.CharField(max_length=100, required=False, default='')
    arabic_text = serializers.CharField(required=False, default='')
    translation = serializers.CharField(required=False, default='')
    audio_url = serializers.URLField(required=False, default='')
    emotion_context = serializers.CharField(max_length=100, required=False, default='')
    note = serializers.CharField(required=False, default='')
