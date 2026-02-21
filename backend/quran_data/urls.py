from django.urls import path
from . import views

urlpatterns = [
    path('favorites/', views.favorites_list, name='favorites-list'),
    path('favorites/add/', views.add_favorite, name='add-favorite'),
    path('favorites/<uuid:favorite_id>/', views.remove_favorite, name='remove-favorite'),
    path('ayah/<int:surah>/<int:ayah>/', views.ayah_detail, name='ayah-detail'),
    path('surahs/', views.surah_list, name='surah-list'),
]
