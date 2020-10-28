# Builder
FROM python:3.8-alpine AS builder

ENV PYTHONDONOTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update
RUN pip install --upgrade pip

COPY . /usr/src/app/
COPY ./requirements.txt .

RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt

# Final
FROM python:3.8-alpine

RUN mkdir -p /home/app && addgroup -S app \
    && adduser -S app -G app

ENV APP_HOME=/home/app/web
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apk update && apk add sudo

COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .

RUN chown -R app:app $APP_HOME && chown -R app:app $HOME
RUN sudo -H pip install --upgrade pip \
    && sudo -H pip install --no-cache /wheels/*

COPY . $APP_HOME
RUN chown -R app:app $APP_HOME

USER app
CMD gunicorn wsgi:app -w 4 --bind 0:5000