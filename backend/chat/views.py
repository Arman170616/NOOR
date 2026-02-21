from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import ChatSession, ChatMessage
from .serializers import (
    ChatSessionSerializer, ChatSessionDetailSerializer,
    ChatMessageSerializer, SendMessageSerializer
)
from .ai_service import analyze_emotion_and_suggest


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def sessions(request):
    """List all sessions or create a new one."""
    if request.method == 'GET':
        user_sessions = ChatSession.objects.filter(user=request.user)
        serializer = ChatSessionSerializer(user_sessions, many=True)
        return Response(serializer.data)

    # POST: create new session
    session = ChatSession.objects.create(
        user=request.user,
        title=request.data.get('title', '')
    )
    serializer = ChatSessionSerializer(session)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['GET', 'DELETE'])
@permission_classes([IsAuthenticated])
def session_detail(request, session_id):
    """Get session with messages or delete it."""
    try:
        session = ChatSession.objects.get(id=session_id, user=request.user)
    except ChatSession.DoesNotExist:
        return Response({'error': 'Session not found'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'DELETE':
        session.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    serializer = ChatSessionDetailSerializer(session)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_message(request):
    """Send a message and get AI response with Quran guidance."""
    serializer = SendMessageSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    user_message = serializer.validated_data['message']
    session_id = serializer.validated_data.get('session_id')

    # Get or create session
    if session_id:
        try:
            session = ChatSession.objects.get(id=session_id, user=request.user)
        except ChatSession.DoesNotExist:
            return Response({'error': 'Session not found'}, status=status.HTTP_404_NOT_FOUND)
    else:
        # Auto-generate title from first message
        title = user_message[:50] + ('...' if len(user_message) > 50 else '')
        session = ChatSession.objects.create(user=request.user, title=title)

    # Build chat history for context
    recent_messages = session.messages.order_by('-created_at')[:10]
    chat_history = [
        {'role': msg.role, 'content': msg.content}
        for msg in reversed(recent_messages)
    ]

    # Save user message
    user_msg = ChatMessage.objects.create(
        session=session,
        role='user',
        content=user_message,
    )

    # Get AI response
    ai_result = analyze_emotion_and_suggest(user_message, chat_history)

    emotion = ai_result.get('emotion', '')
    ai_response_text = ai_result.get('response', '')
    quran_suggestions = ai_result.get('quran_suggestions', [])

    # Save assistant message
    assistant_msg = ChatMessage.objects.create(
        session=session,
        role='assistant',
        content=ai_response_text,
        emotion=emotion,
        quran_suggestions=quran_suggestions,
    )

    # Update session title if first message
    if session.messages.count() <= 2 and not session.title:
        session.title = user_message[:50]
        session.save()

    return Response({
        'session_id': str(session.id),
        'user_message': ChatMessageSerializer(user_msg).data,
        'assistant_message': ChatMessageSerializer(assistant_msg).data,
    }, status=status.HTTP_201_CREATED)
