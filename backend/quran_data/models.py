import uuid
from django.db import models
from authentication.models import User


class FavoriteAyah(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favorite_ayahs')
    surah_number = models.IntegerField()
    ayah_number = models.IntegerField()
    number_in_quran = models.IntegerField(default=0)
    surah_name = models.CharField(max_length=100)
    surah_name_arabic = models.CharField(max_length=100, blank=True)
    arabic_text = models.TextField(blank=True)
    translation = models.TextField(blank=True)
    audio_url = models.URLField(blank=True)
    emotion_context = models.CharField(max_length=100, blank=True)
    note = models.TextField(blank=True)
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'favorite_ayahs'
        unique_together = ['user', 'surah_number', 'ayah_number']
        ordering = ['-added_at']

    def __str__(self):
        return f"{self.surah_name} {self.surah_number}:{self.ayah_number}"
