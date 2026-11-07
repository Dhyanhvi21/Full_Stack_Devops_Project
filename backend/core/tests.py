from django.test import TestCase, Client

class CoreApiTests(TestCase):
    def setUp(self):
        self.client = Client()

    def test_hello_endpoint(self):
        response = self.client.get('/api/hello/')
        self.assertEqual(response.status_code, 200)
        self.assertJSONEqual(
            response.content,
            {"message": "Hello World from Django Backend!"}
        )

    def test_health_endpoint(self):
        response = self.client.get('/api/health/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json().get("status"), "healthy")
