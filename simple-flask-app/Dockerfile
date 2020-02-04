FROM python:3.8.1-alpine

COPY . .

RUN pip install -r requirements.txt

ENV FLASK_APP=app

CMD ["flask", "run", "--host", "0.0.0.0"]