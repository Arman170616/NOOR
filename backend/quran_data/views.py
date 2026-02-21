import requests
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import FavoriteAyah
from .serializers import FavoriteAyahSerializer, AddFavoriteSerializer

ALQURAN_BASE = "https://api.alquran.cloud/v1"
AUDIO_BASE = "https://cdn.islamic.network/quran/audio/128/ar.alafasy"


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def favorites_list(request):
    """List user's favorite ayahs."""
    favorites = FavoriteAyah.objects.filter(user=request.user)
    serializer = FavoriteAyahSerializer(favorites, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_favorite(request):
    """Add an ayah to favorites."""
    serializer = AddFavoriteSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    data = serializer.validated_data
    favorite, created = FavoriteAyah.objects.get_or_create(
        user=request.user,
        surah_number=data['surah_number'],
        ayah_number=data['ayah_number'],
        defaults={
            'number_in_quran': data.get('number_in_quran', 0),
            'surah_name': data['surah_name'],
            'surah_name_arabic': data.get('surah_name_arabic', ''),
            'arabic_text': data.get('arabic_text', ''),
            'translation': data.get('translation', ''),
            'audio_url': data.get('audio_url', ''),
            'emotion_context': data.get('emotion_context', ''),
            'note': data.get('note', ''),
        }
    )

    if not created:
        return Response(
            {'message': 'Already in favorites'},
            status=status.HTTP_200_OK
        )

    out = FavoriteAyahSerializer(favorite)
    return Response(out.data, status=status.HTTP_201_CREATED)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def remove_favorite(request, favorite_id):
    """Remove an ayah from favorites."""
    try:
        favorite = FavoriteAyah.objects.get(id=favorite_id, user=request.user)
    except FavoriteAyah.DoesNotExist:
        return Response({'error': 'Not found'}, status=status.HTTP_404_NOT_FOUND)

    favorite.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def ayah_detail(request, surah, ayah):
    """Fetch ayah details from Al-Quran Cloud."""
    ref = f"{surah}:{ayah}"
    try:
        ar = requests.get(f"{ALQURAN_BASE}/ayah/{ref}", timeout=8)
        en = requests.get(f"{ALQURAN_BASE}/ayah/{ref}/en.sahih", timeout=8)

        arabic = ar.json().get('data', {}) if ar.ok else {}
        english = en.json().get('data', {}) if en.ok else {}

        number_in_quran = arabic.get('number', 0)
        audio_url = f"{AUDIO_BASE}/{number_in_quran}.mp3" if number_in_quran else ""

        return Response({
            'surah_number': surah,
            'ayah_number': ayah,
            'number_in_quran': number_in_quran,
            'surah_name': arabic.get('surah', {}).get('englishName', ''),
            'surah_name_arabic': arabic.get('surah', {}).get('name', ''),
            'arabic_text': arabic.get('text', ''),
            'translation': english.get('text', ''),
            'audio_url': audio_url,
            'is_favorite': FavoriteAyah.objects.filter(
                user=request.user, surah_number=surah, ayah_number=ayah
            ).exists()
        })
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def surah_list(request):
    """Get list of all 114 surahs."""
    try:
        resp = requests.get(f"{ALQURAN_BASE}/surah", timeout=8)
        if resp.ok:
            return Response(resp.json().get('data', []))
        return Response({'error': 'Failed to fetch surahs'}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
