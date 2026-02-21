import json
import logging
import requests
from django.conf import settings
import anthropic

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """You are Noor (نور - meaning Light), a compassionate Islamic spiritual guide embedded in a Quran guidance app.

Your role is to provide emotional support through the wisdom of the Holy Quran. When someone shares their feelings with you, you:
1. Acknowledge their emotions with deep empathy and Islamic compassion
2. Provide a warm, comforting response rooted in Islamic perspective
3. Suggest 1-3 highly relevant Quranic verses that address their specific emotional state

IMPORTANT: Always respond with ONLY valid JSON in exactly this format (no markdown, no extra text):
{
    "emotion": "the primary emotion detected (e.g. sadness, anxiety, hopelessness, anger, fear, loneliness, stress, boredom, gratitude)",
    "response": "Your warm, empathetic response (2-4 sentences). Acknowledge their feeling, provide Islamic comfort, and lead into the Quranic guidance.",
    "quran_suggestions": [
        {
            "surah_number": <integer>,
            "surah_name": "<English name>",
            "surah_name_arabic": "<Arabic name>",
            "ayah_number": <integer>,
            "arabic_text": "<The Ayah in Arabic>",
            "translation": "<Simple English translation>",
            "explanation": "<1-2 sentences: why this verse speaks to their emotion and how it can bring comfort>"
        }
    ]
}

Emotion to Quran mapping guidelines:
- Sadness/Grief: Ad-Duha (93:3), Al-Inshirah (94:5-6), Al-Baqarah (2:286)
- Anxiety/Worry: Al-Inshirah (94:5-6), Al-Baqarah (2:286), Ar-Ra'd (13:28)
- Hopelessness/Despair: Az-Zumar (39:53), Yusuf (12:87), Al-Baqarah (2:112)
- Fear: Al-Baqarah (2:255 - Ayatul Kursi), At-Talaq (65:3), Al-Anfal (8:30)
- Loneliness: Al-Hadid (57:4), Ad-Duha (93:3), Al-Mujadila (58:7)
- Anger: Al-Imran (3:134), Al-Araf (7:199), Ash-Shura (42:37)
- Stress/Overwhelmed: Al-Inshirah (94:5-8), Al-Baqarah (2:286), Al-Talaq (65:3)
- Boredom/Emptiness: Al-Kahf (18:10), Ad-Duha (93:4-5), Al-Hadid (57:20)
- Gratitude: Ibrahim (14:7), Al-Fatiha (1:1-7), Al-Imran (3:145)
- Lost/Confused: Al-Fatihah (1:6), Al-Baqarah (2:186), Al-Kahf (18:10)
"""

ALQURAN_BASE = "https://api.alquran.cloud/v1"
AUDIO_BASE = "https://cdn.islamic.network/quran/audio/128/ar.alafasy"


def get_ayah_details(surah_number, ayah_number):
    """Fetch ayah details from Al-Quran Cloud API."""
    try:
        ref = f"{surah_number}:{ayah_number}"
        # Arabic text
        ar_resp = requests.get(f"{ALQURAN_BASE}/ayah/{ref}", timeout=5)
        # English translation
        en_resp = requests.get(f"{ALQURAN_BASE}/ayah/{ref}/en.sahih", timeout=5)

        arabic_data = ar_resp.json().get('data', {}) if ar_resp.ok else {}
        english_data = en_resp.json().get('data', {}) if en_resp.ok else {}

        number_in_quran = arabic_data.get('number', 0)
        audio_url = f"{AUDIO_BASE}/{number_in_quran}.mp3" if number_in_quran else ""

        return {
            'number_in_quran': number_in_quran,
            'audio_url': audio_url,
            'arabic_text': arabic_data.get('text', ''),
            'translation': english_data.get('text', ''),
            'surah_name': arabic_data.get('surah', {}).get('englishName', ''),
            'surah_name_arabic': arabic_data.get('surah', {}).get('name', ''),
        }
    except Exception as e:
        logger.warning(f"Failed to fetch ayah {surah_number}:{ayah_number}: {e}")
        return {}


def analyze_emotion_and_suggest(user_message, chat_history=None):
    """Call Claude API to analyze emotion and get Quran suggestions."""
    if not settings.ANTHROPIC_API_KEY:
        return get_fallback_response(user_message)

    client = anthropic.Anthropic(api_key=settings.ANTHROPIC_API_KEY)

    messages = []
    if chat_history:
        for msg in chat_history[-6:]:  # Last 3 exchanges for context
            messages.append({"role": msg['role'], "content": msg['content']})

    messages.append({"role": "user", "content": user_message})

    try:
        with client.messages.stream(
            model="claude-opus-4-6",
            max_tokens=2048,
            thinking={"type": "adaptive"},
            system=SYSTEM_PROMPT,
            messages=messages,
        ) as stream:
            final = stream.get_final_message()

        text = next(
            (b.text for b in final.content if hasattr(b, 'text')),
            '{}'
        )

        # Strip any markdown code blocks if present
        text = text.strip()
        if text.startswith('```'):
            text = text[text.find('{'):]
            text = text[:text.rfind('}') + 1]

        result = json.loads(text)

        # Enrich suggestions with audio URLs from Al-Quran Cloud
        for suggestion in result.get('quran_suggestions', []):
            details = get_ayah_details(
                suggestion.get('surah_number'),
                suggestion.get('ayah_number')
            )
            if details:
                suggestion.setdefault('audio_url', details.get('audio_url', ''))
                suggestion.setdefault('number_in_quran', details.get('number_in_quran', 0))
                if not suggestion.get('arabic_text'):
                    suggestion['arabic_text'] = details.get('arabic_text', '')
                if not suggestion.get('translation'):
                    suggestion['translation'] = details.get('translation', '')

        return result

    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse Claude response as JSON: {e}")
        return get_fallback_response(user_message)
    except Exception as e:
        logger.error(f"Claude API error: {e}")
        return get_fallback_response(user_message)


FALLBACK_RESPONSES = {
    'default': {
        "emotion": "seeking comfort",
        "response": "I hear you, dear soul. Whatever you're going through, remember that Allah (SWT) is always near. The Quran is full of light for every kind of darkness. Here are some verses that may speak to your heart.",
        "quran_suggestions": [
            {
                "surah_number": 94,
                "surah_name": "Al-Inshirah",
                "surah_name_arabic": "الشرح",
                "ayah_number": 6,
                "arabic_text": "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
                "translation": "Indeed, with hardship will be ease.",
                "explanation": "Allah promises that ease always accompanies hardship — not after it, but with it.",
                "audio_url": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/596.mp3",
                "number_in_quran": 596
            }
        ]
    }
}


def get_fallback_response(user_message):
    """Return a fallback response when Claude is unavailable."""
    return FALLBACK_RESPONSES['default']
