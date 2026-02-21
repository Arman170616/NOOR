from django.urls import path
from . import views

urlpatterns = [
    path('sessions/', views.sessions, name='sessions'),
    path('sessions/<uuid:session_id>/', views.session_detail, name='session-detail'),
    path('message/', views.send_message, name='send-message'),
]
