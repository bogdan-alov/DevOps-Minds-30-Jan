import tweepy
import requests
import boto3
import json
import random
import os

from flask import Flask, request

app = Flask(__name__)

# Variables
S3_BUCKET = "python-app-memes"
QUOTES_API = "https://api.quotable.io/random"
CONSUMER_TOKEN = os.environ['CONSUMER_TOKEN']
CONSUMER_SECRET = os.environ['CONSUMER_SECRET']
TWITTER_API_ACCESS_KEY = os.environ['TWITTER_API_ACCESS_KEY']
TWITTER_API_SECRET_KEY = os.environ['TWITTER_API_SECRET_KEY']

# Twitter authentication
auth = tweepy.OAuthHandler(CONSUMER_TOKEN, CONSUMER_SECRET)
auth.set_access_token(TWITTER_API_ACCESS_KEY, TWITTER_API_SECRET_KEY)
api = tweepy.API(auth)

s3 = boto3.client('s3')


@app.route('/', methods=['GET'])
def Index():
	return "It seems to work.", 200


@app.route('/meme', methods=['GET'])
def Meme():
	try:
		# Get S3 bucket objects count
		objs = s3.list_objects(Bucket="python-app-memes")

		# Get random meme
		random_meme = random.randint(0, len(objs['Contents']) - 1)

		# Get random name
		filename = "meme{}.jpg".format(random_meme)

		# Download file in S3
		s3.download_file(S3_BUCKET, filename, filename)

		# Tweet with image
		api.update_with_media(filename)

		# Remove image
		os.remove(filename)

	except Exception as e:
		print(e)

		return "Oops, something went wrong...", 400

	return "Succesfully updated status with meme!", 200


@app.route('/quote', methods=['GET'])
def Quote():
	try:
		# Take random quote
		res = requests.get(QUOTES_API)

		json_obj = json.loads(res.content)

		# Quote of the day
		quote = '"{}" {}'.format(json_obj['content'], json_obj['author'])

		# Tweet
		api.update_status(quote)

	except Exception as e:
		print(e)

		return "Oops, something went wrong...", 400

	return "Succesfully updated status with quote!", 200


if __name__ == "__main__":
	app.run()
