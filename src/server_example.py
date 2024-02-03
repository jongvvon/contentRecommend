from flask import Flask, request
from googleapiclient.discovery import build
import json

app = Flask(__name__)

def youtube_search(keyword):
    youtube = build('youtube', 'v3', developerKey='AIzaSyAPCRTi_VeV5pb5uJcRa6p6MfXJ6NkjysM')

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
