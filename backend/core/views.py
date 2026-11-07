from django.http import JsonResponse

def hello_world(request):
    return JsonResponse({"message": "Hello World from Django Backend!"})

def health_check(request):
    return JsonResponse({"status": "healthy", "service": "django-backend"})
