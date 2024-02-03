from flask import Flask, request
from googleapiclient.discovery import build
import json, os

app = Flask(__name__)

youtube_api_key = os.getenv('YOUTUBE_API_KEY')

def youtube_search(keyword):
    youtube = build('youtube', 'v3', developerKey=youtube_api_key)

    request = youtube.search().list(
        part='snippet',
        maxResults=3,
        q=keyword
    )
    response = request.execute()

    video_ids = [item['id']['videoId'] for item in response['items']]

    return video_ids

@app.route('/recommendations', methods=['GET'])
def get_recommendations():
    emotion = request.args.get('emotion') 
    video_ids = youtube_search(emotion) 

    if not video_ids:
        return 'No results found', 404

    return json.dumps(video_ids), 200 

if __name__ == '__main__':
    app.run(debug=True)
