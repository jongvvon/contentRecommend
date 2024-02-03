from server_example import youtube_search, app
import unittest
import json

class YouTubeApiTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        
    def test_youtube_search(self):
        video_ids = youtube_search('happy')
        self.assertIsNotNone(video_ids)
        self.assertEqual(len(video_ids), 3)

    def test_get_recommendations(self):
        response = self.app.get('/recommendations', query_string={'emotion': 'happy'})
        self.assertEqual(response.status_code, 200)
        video_ids = json.loads(response.data)
        self.assertEqual(len(video_ids), 3)

if __name__ == '__main__':
    unittest.main()
